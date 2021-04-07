# Ruby service that uses Prawn gem to create flyer

#### Client is a local Real Estate co.

## Entry point of the service is a shell executable

`./bin/bayshore_pdf_writer` 


The executable expects a path to a json file with a specific structure.. 

`$> ./bin/bayshore_pdf_writer -f /PATH_TO_FILE/file.json`

This service will in turn launch a ruby process - generate a pdf and place it back in a specified directory.

### example-with-required-structure.json 


```
{
  "qr_code": "path-to/qrcode-381.png",
  "property_type": "buy",
  "photos": [
    {
      "large_photo_url": "http://image-url-path/file.jpg"
    },
    {
      "large_photo_url": "http://image-url-path/file.jpg"
    },
    {
      "large_photo_url": "http://image-url-path/file.jpg"
    }
  ],
  "main_photo": {
    "large_photo_url":"http://image-url-path/file.jpg"
  },
  "location": { "street_name": "Yoli village", "city": "Savusavu" },
  "listing_type": "land",
  "has_qr_code": true,
  "details": {
    "type": "Land for Residential Use",
    "title_description": "Freehold land for sale",
    "tender": "For Sale",
    "listing_price": 9999,
    "full_description": "Just an opportunity to grab this 1 acre Freehold Land at a very affordable price.Features to build a Dream Home .\r\n A piece of land that can be used for farming as well as treasured for retirement.\r\n",
    "car_spaces": null,
    "bedrooms": 1,
    "bathrooms": 3
  },
  "agent": {
    "profile_image": "image-url-path",
    "phone_number": "9707253",
    "last_name": "Maharaj",
    "first_name": "Jerome",
    "email": "someemail@address.com"
  }
}
```

## Result will be a pdf similar to this one.

<img width="300px" src="tmp/real-estate-flyer.png">