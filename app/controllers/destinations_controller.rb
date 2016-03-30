class DestinationsController < ApplicationController
  def index
    signature = Digest::SHA256.hexdigest "4whec3tnzq9abhrx2ku9n78t" + "bS6CCG3tkc" + Time.now.to_i.to_s
    request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-content-api/1.0/locations/destinations",
      method: :get,
      params: {
        fields: "all",
        countryCodes: "MX",
        language: "CAS",
        from: 1,
        to: 100
      },
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    request.run
    @response = request.response
    @body = JSON.parse @response.body
  end
end
