module Import
  class CSVFromStGeorg
    HEADER_MATCHER =  /\A.?Belegungsnummer;VermieterNummer;Gruppenname;.*;Kundennummer;/
    DATE_FORMAT = '%d.%m.%Y'
    DATETIME_FORMAT = '%d.%m.%Y %H:%M'

    def self.csv_options
      { headers: true, converters: :all, header_converters: :symbol, col_sep: ',' }
    end

    def process_files(files = Dir[Rails.root.join('tmp', 'import', '*.csv')])
      Import::Result.wrap do |result|
        files = case files
                when String
                  files.split(';')
                else
                  files
                end

        files.each { |file| process_file(file, result) }
      end
    end

    def process_stdin
      puts "Reading from stdin"
      result = Import::Result.wrap do |result|
        ::CSV.parse(STDIN.read, self.class.csv_options) do |row|
          result << BookingRow.process(row)
        end
      end
      puts result.to_s
    end

    def process_file(file, result)
      ::CSV.foreach(file, self.class.csv_options) do |row|
        result << BookingRow.process(row)
      end
    end

    class TenantRow
      attr_reader :row

      def initialize(row)
        @row = row
      end

      # rubocop:disable Metrics/AbcSize
      def build
        ::Tenant.find_or_initialize_by(email: email).tap do |tenant|
          tenant.assign_attributes(
            id: id, first_name: row[:mietervorname], last_name: row[:mietername],
            street_address: [row[:mieteradresse], row[:mieteradresszusatz]].join("\n"), zipcode: row[:mieterplz],
            city: row[:mieterort], country: country, phone: phone,
            reservations_allowed: true, remarks: row[:mieterbemerkungen], import_data: row.to_h
          )
        end
      end
      # rubocop:enable Metrics/AbcSize

      def email
        "mieter+#{id}@heimv.local"
        # row[:mieteremail].presence || "mieter+#{id}@heimv.local"
      end

      def id
        row[:kundennummer]
      end

      def phone
        [row[:mieterteln], row[:mietertelp], row[:mietertelg]].select(&:present?).join("\n")
      end

      def country
        country = ISO3166::Country.find_by(name: row[:mieterland])
        country.first
      rescue NoMethodError
        'CH'
      end
    end

    class BookingRow
      PURPOSE_MATCHER = {
        'lager' => :camp,
        'fest' => :event
      }.freeze
      attr_reader :row

      def initialize(row)
        @row = row
      end

      # rubocop:disable Metrics/AbcSize
      def build
        Booking.find_or_initialize_by(ref: ref) do |booking|
          booking.assign_attributes(
            ref: ref, tenant_organisation: tenant_organisation, remarks: remarks, occupancy: occupancy,
            home: home, approximate_headcount: approximate_headcount, purpose: purpose, import_data: row.to_h,
            email: tenant&.email, committed_request: true, invoice_address: invoice_address, tenant: tenant,
            transition_to: :definitive_request, messages_enabled: false
          )
        end
      end
      # rubocop:enable Metrics/AbcSize

      def create
        booking = build
        return booking unless booking.save
        create_associated_records(booking)
      end

      def create_associated_records(booking)
        invoice = Invoice.create(booking: booking, invoice_type: :deposit, amount: row[:anzahlung])

        paid_at = parse_date(row[:anzahlungbezahltam])
        Payment.create(booking: booking, invoice: invoice, amount: invoice.amount, paid_at: paid_at) if paid_at

        sent_at = parse_date(row[:vertragsdatum])
        signed_at = row[:vertragzurck] == "TRUE" ? Time.zone.now : nil
        contract = Contract.create(booking: booking, valid_from: sent_at, sent_at: sent_at, signed_at: signed_at) if sent_at
      end

      def self.process(row)
        return nil if row[:belegungsnummer].blank?

        new(row).create
      end

      private

      def parse_date(date, time = nil)
        return if date.blank?

        if time.present?
          Time.zone.strptime([date, time].join(' '), DATETIME_FORMAT)
        else
          Time.zone.strptime(date, DATE_FORMAT)
        end
      rescue ArgumentError
        nil
      end

      def approximate_headcount
        row.fetch(:anzahlkinder, 0) + row.fetch(:anzahljugendliche, 0) + row.fetch(:anzahlerwachsene, 0)
      end

      def home
        return Home.find_by(ref: :muehli) if row[:belegungsnummer].start_with?('M')
        return Home.find_by(ref: :villa) if row[:belegungsnummer].start_with?('K')
        return Home.find_by(ref: :bir) if row[:belegungsnummer].start_with?('B')
      end

      def purpose
        PURPOSE_MATCHER.fetch(row[:zweck], nil)
      end

      def occupancy
        Occupancy.new(
          occupancy_type: :occupied,
          begins_at: Time.zone.strptime("#{row[:ankunftsdatum]} #{row[:ankunftszeit]}", DATETIME_FORMAT),
          ends_at: Time.zone.strptime("#{row[:abreisedatum]} #{row[:abreisezeit]}", DATETIME_FORMAT)
        )
      rescue ArgumentError, TypeError
        nil
      end

      def invoice_address
        return row[:rechnungan] if row[:rechnungan].present?

        <<~ADDRESS
        #{row[:rechnungvorname]} #{row[:rechnungname]}
        #{row[:rechnungadresse]}
        #{row[:rechnungplz]} #{row[:rechnungort]} #{row[:rechnungland]}
        ADDRESS
      end

      def remarks
        row[:bemerkungen]
      end

      def tenant
        @tenant ||= TenantRow.new(row).build
      end

      def tenant_organisation
        row[:gruppenname]
      end

      def ref
        row[:belegungsnummer]
      end
    end
  end
end
