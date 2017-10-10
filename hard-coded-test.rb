require 'prawn'
require 'json'

user = File.read('user.json')
user_hash = JSON.parse(user)
deals = File.read('deals.json')
deals_hash = JSON.parse(deals)

pdf = Prawn::Document.new

pdf.move_cursor_to 720

# This is the user info boudning box, it's not expected that the height will
# ever exceed 1 line per item
pdf.bounding_box([0, pdf.cursor], :width => 540) do
  pdf.font_size 16
  pdf.text "#{user_hash['data']['first_name']} #{user_hash['data']['last_name']}"
  pdf.font_size 12
  pdf.text "#{user_hash['data']['title']}"
  pdf.text "#{user_hash['data']['company']}"
  pdf.text "#{user_hash['data']['email']}"
end

pdf.move_down 15

# Begin loop for all user deals
# bounds are stroked only for illustration, will not be in final
deals_hash.each do |key, value|
  # Outer bounding box (Box A in Google group question)
  pdf.bounding_box([0, pdf.cursor], :width => 540) do
    pdf.font_size 16
    pdf.text "#{key['headline']}"
    pdf.move_down 10
    # Inner bounding box containing client names (box B in question)
    pdf.bounding_box([0, pdf.cursor], :width => 235) do
      pdf.font_size 12
      key['clients'].each do |client|
        pdf.bounding_box([0, pdf.cursor], :width => 135) do
          pdf.text client['client']
        end
        pdf.stroke_bounds
      end
      # Inner bounding box (Box C in question)
      # In one edge case it could be taller than Box B
      pdf.move_cursor_to pdf.bounds.top
      key['clients'].each do |role|
        pdf.bounding_box([136, pdf.cursor], :width => 100) do
          pdf.text role['role']
        end
        pdf.stroke_bounds
      end
      pdf.move_cursor_to pdf.bounds.top
    end
    # Final inner bounding box (Box D in question)
    pdf.bounding_box([236, pdf.cursor], :width => 304) do
      pdf.text key['summary_tasks']
      pdf.stroke_bounds
    end
    pdf.stroke_bounds
  end
  # This was my last attempt to determine the bottom of the bouding box, but
  # as you can see from the pdf, it's not working
  pdf.move_down(pdf.bounds.absolute_bottom - 15)
end



pdf.render_file("list test.pdf")
