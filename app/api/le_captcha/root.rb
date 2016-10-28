module LeCaptcha
  class Root < Grape::API
    format :json

    get '' do
      'root path'
    end

    add_swagger_documentation(
      mount_path: Rails.configuration.x.swagger_doc_path
    )
  end
end
