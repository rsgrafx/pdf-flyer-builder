require 'prawn'
require 'json'
require 'open-uri'
require 'erb'


include ERB::Util

Prawn::Fonts::AFM.hide_m17n_warning = true

class Flyer
  @@backgroundColor = '000000'
  @@orange = "ff5921"
  @@text_color = 'ffffff'

  @@uri = URI::Parser.new


  def self.run_from_path(path) 
    run({file_path: path})
  end

  def self.run(options)
    file_data = {}
    file_path = options[:file_path]
    # puts options
        
    file_data[:name] = File.basename(file_path, ".*")
    file_data[:dir] = dir = File.dirname(file_path)
    # puts file_data.inspect    
    file = File.open(file_path)
    
    file_data[:parsed] = Hash[JSON.parse(file.read).map {|k, v| [k.to_sym, v]}]
    
    Prawn::Document.generate("#{dir}/data-one-#{file_data[:name]}.pdf") do
      
    font_families.update(
        'Clear Sans' => { 
          normal: 'assets/fonts/ClearSans-Regular.ttf',
          bold: 'assets/fonts/ClearSans-Bold.ttf',
          thin: 'assets/fonts/ClearSans-Thin.ttf'
        }
      )

      font 'Clear Sans'
      parsed = file_data[:parsed]
  
      # Creates a black rectangle.
      canvas do
        fill_color @@backgroundColor
        fill_rectangle([0, cursor], 800, 1000)
      end

      # create_stamp('for-sale') do
      #   rotate(30, origin: [-5, -5]) do
      #     stroke_color @@orange
      #     fill_color @@orange

      #     font('Clear Sans') do 
      #       draw_text 'For Sale', at: [-23, -3], color: 'ffffff'
      #     end
      #     fill_color @@orange
      #   end
      # end

      bounding_box([0, cursor], width: 600, height: 400) do
        main_photo_url = parsed[:main_photo]["large_photo_url"]
        image URI.open(@@uri.escape(main_photo_url)), fit: [600, 350]
        
        fill_color @@orange
        fill_rectangle([-100, cursor+10], 800, 60)
      end

      # stamp_at 'for-sale', at: [10, 650]
      
      unless parsed[:agent]["profile_image"].is_a? NilClass
        agent_image_url = @@uri.escape(parsed[:agent]["profile_image"])
        image URI.open(agent_image_url), fit: [130, 150], at: [390, 460]
      end

      @inset_photo = parsed[:photos][-1]["large_photo_url"]
      image URI.open(@@uri.escape(@inset_photo)), width: 200, at: [300, 700]

      bounding_box([0, cursor+50], width: 600, height: 400) do
        # Address
        font 'Clear Sans', style: :bold
        font_size 23
        location = parsed[:location]
        # font :Helvetica, style: :bold
        address = "#{location["street_name"]}, #{location["city"]}"
        text address, color: 'ffffff'
        # Property Description
        # move_down 5
        font_size 18
        text parsed[:details]["title_description"], color: "000000"
        
        bounding_box([0, cursor - 10], width: 540, height: 300) do
          define_grid(columns: 12, rows: 4)
          
          grid(0, 0).bounding_box do
            image "assets/bed.png", width: 40
          end

          grid(0, 1).bounding_box do
            move_down 10
            text "#{parsed[:details]["bedrooms"]}", color: 'ffffff'
          end

          grid(0, 2).bounding_box do
            image "assets/bath.png", width: 40
          end

          grid(0, 3).bounding_box do
            move_down 10
            text "#{parsed[:details]["bathrooms"]}", color: 'ffffff'
          end

          grid(0, 4).bounding_box do
            image "assets/car.png", width: 40
          end

          grid(0, 5).bounding_box do
            move_down 10
            text "#{parsed[:details]["car_spaces"]}", color: 'ffffff'
          end

          grid([0, 6], [3, 11]).bounding_box do
            fill_color 'fff333'
            font_size 12
            text parsed[:details]["full_description"], color: @@text_color            
          end

          grid([1, 0], [2, 5]).bounding_box do

            font_size 25
            font 'Clear Sans', style: :bold
            text "#{parsed[:agent]["first_name"]} #{parsed[:agent]["last_name"]}", color: @@text_color
            font_size 20
            font 'Clear Sans', style: :bold
            text "Ph: #{parsed[:agent]["phone_number"]}", color: @orange
            font_size 15
            font 'Clear Sans', style: :normal
            text "Email: #{parsed[:agent]["email"]}", color: @@text_color
          end          

          grid([3,0], [3,5]).bounding_box do
            move_down 10
            image "assets/bayshore-logo.png", width: 150, at: [10, 20]
            font_size 20
            text "Lic. NO. #011", color: @@text_color
          end

          # grid([3,6], [3,11]).bounding_box do
          #   # font_size 20
          # end
          # grid.show_all
          
        end
      
      end
      fill_color @@orange
      fill_rectangle([-100, cursor], 800, 10)
    end
  end
end
