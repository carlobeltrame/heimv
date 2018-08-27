require "prawn"

module PDF
  class Contract
    include Prawn::View

    def initialize(contract)
      @contract = contract
      @markdown = MarkdownService.new(contract.text)
    end

    def document
      @my_prawn_doc ||= Prawn::Document.new(
        page_size: 'A4',
        optimize_objects: true,
        margin: [50] * 4
        )
    end

    def build
      build_header
      build_addresses

      move_down 20
      text "Mietvertrag", size: 20, style: :bold
      text @contract.booking.home.name, size: 12

      move_down 20
      text @markdown.html_body, inline_format: true
      self
    end

    def build_header
      image Rails.root.join('app', 'webpack', 'images', 'logo_hvs.png'), at: [bounds.top_left[0] - 25, bounds.top_left[1] + 35], width: 120
    end

    def build_addresses
        bounding_box [0, 670], width: 200, height: 170 do
          default_leading 3
          text "Vermieter", size: 16, style: :bold
          move_down 5
          text "vertreten durch:", size: 9
          text "Verein Pfadiheime St. Georg\nHeimverwaltung\nChristian Morger\nGeeringstr. 44\n8049 Zürich", size: 10
          text "\nTel: 079 262 25 48\nEmail: info@pfadi-heime.ch", size: 9
        end

        bounding_box [300, 670], width: 200, height: 170 do
          default_leading 4
          text "Mieter", size: 16, style: :bold
          move_down 5
          text @contract.booking.ref, size: 9
          text @contract.booking.organisation, size: 9
          text @contract.booking.customer.address_lines.join("\n"), size: 11
        end
    end
  end
end
