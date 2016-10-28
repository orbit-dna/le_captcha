module LeCaptcha
  class Root < Grape::API
    format :json

    get '' do
      'root path'
    end
    # add_swagger_documentation
  end
end
