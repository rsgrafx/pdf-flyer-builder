require_relative './loaders.rb'

include ERB::Util

Prawn::Fonts::AFM.hide_m17n_warning = true

class Flyer
  @@backgroundColor = '000000'
  @@orange = "ff5921"
  @@text_color = 'ffffff'
  @@residential = ["apartment", "home", "flat"]

  @@uri = URI::Parser.new

  @@asset_path = File.dirname(File.expand_path(__FILE__)) + "/assets"

  def self.run_from_path(path) 
    Flyer.run(path)
  end

  def self.run(file_path)
    file_data = {}

    file_data[:name] = File.basename(file_path, ".*")
    file_data[:dir] = dir = File.dirname(file_path)

    file = File.open(file_path)    
    file_data[:parsed] = Hash[JSON.parse(file.read).map {|k, v| [k.to_sym, v]}]

    Prawn::Document.generate("#{dir}/#{file_data[:name]}.pdf") do
    parsed = file_data[:parsed]

    font_families.update(
        'Clear Sans' => { 
          normal: "#{@@asset_path}/fonts/ClearSans-Regular.ttf",
          bold: "#{@@asset_path}/fonts/ClearSans-Bold.ttf",
          thin: "#{@@asset_path}/fonts/ClearSans-Thin.ttf"
        }
      )

      font 'Clear Sans'
      # Creates a black rectangle.
      canvas do
        fill_color @@backgroundColor
        fill_rectangle([0, cursor], 800, 1000)
      end

      bounding_box([0, cursor], width: 600, height: 400) do
        main_photo_url = parsed[:main_photo]["large_photo_url"]
        image URI.open(@@uri.unescape(main_photo_url)), fit: [600, 350]
        
        fill_color @@orange
        fill_rectangle([-100, cursor+10], 800, 60)
      end

      @sale_type = parsed[:details]["tender"] || "For Sale"

      rotate(30, origin: [50, 700]) do
        fill_color @@orange
        fill_rectangle([-90, 700], 400, 50)
        fill_color 'ffffff'
        font_size 40
        font 'Clear Sans', style: :bold
        draw_text @sale_type, at: [10, 660]
      end
      
      unless parsed[:agent]["profile_image"].is_a? NilClass
        agent_image_url = @@uri.escape(parsed[:agent]["profile_image"])
        image URI.open(agent_image_url), fit: [130, 150], at: [390, 480]
      end

      @inset_photo = parsed[:photos][-1]["large_photo_url"]
      begin 
      image URI.open(@@uri.escape(@inset_photo)), width: 200, at: [325, 710]
      rescue OpenURI::HTTPError => e
        puts "#{e.inspect}"
        image URI.open(@@uri.unescape(@inset_photo)), width: 200, at: [325, 710]
      end
      
      bounding_box([0, cursor+50], width: 600, height: 400) do
        # Address
        font 'Clear Sans', style: :bold
        font_size 20
        location = parsed[:location]
        address = "#{location["street_name"]}, #{location["city"]}"
        text address, color: 'ffffff'

        # Property Description
        font_size 16
        text parsed[:details]["title_description"], color: "000000"
        
        bounding_box([0, cursor - 10], width: 540, height: 300) do
          define_grid(columns: 12, rows: 4)
          
          if @@residential.include? parsed[:listing_type] 
            grid(0, 0).bounding_box do
              image "#{@@asset_path}/bed.png", width: 40
            end

            grid(0, 1).bounding_box do
              move_down 10
              text "#{parsed[:details]["bedrooms"]}", color: 'ffffff'
            end

            grid(0, 2).bounding_box do
              image "#{@@asset_path}/bath.png", width: 40
            end

            grid(0, 3).bounding_box do
              move_down 10
              text "#{parsed[:details]["bathrooms"]}", color: 'ffffff'
            end

            grid(0, 4).bounding_box do
              image "#{@@asset_path}/car.png", width: 40
            end

            grid(0, 5).bounding_box do
              move_down 10
              text "#{parsed[:details]["car_spaces"]}", color: 'ffffff'
            end
          else
            grid([0, 0], [0, 5]).bounding_box do
              # text parsed[:details]["type"], color: 'ffffff'
            end
          end

          grid([0, 6], [3, 11]).bounding_box do
            fill_color 'fff333'
            font_size 12
            font 'Clear Sans', style: :normal
            move_down 3
            text parsed[:details]["full_description"], color: @@text_color            
          end

          grid([1, 0], [2, 5]).bounding_box do
            font_size 15
            font 'Clear Sans', style: :bold
            text "Call Agent:"
            move_down 10
            font_size 25
            text "#{parsed[:agent]["first_name"]} #{parsed[:agent]["last_name"]}", color: @@orange
            font_size 20
            font 'Clear Sans', style: :bold
            text "Ph: #{parsed[:agent]["phone_number"]}", color: @@orange
            font_size 15
            font 'Clear Sans', style: :normal
            text "Em: #{parsed[:agent]["email"]}", color: @@text_color      
            # end
            if parsed[:has_qr_code]
              qr_code_path = "#{file_data[:dir]}/#{parsed[:qr_code]}"
              image qr_code_path,  width: 100, height: 100, fit: [100, 100], at: [10, 40]
            end
          end          

          grid([3,0], [3,5]).bounding_box do
            move_down 10
            image "#{@@asset_path}/bayshore-logo.png", width: 150, at: [5, 8]
            font_size 20
            font 'Clear Sans', style: :bold
            fill_color 'ffffff'
            draw_text "Lic. NO. #0166", at: [400, -12]
          end          
        end
      
      end
      
      fill_color @@orange
      fill_rectangle([-100, cursor], 800, 10)
    end
  end
end
