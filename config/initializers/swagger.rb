GrapeSwaggerRails.options.url = Rails.configuration.x.swagger_doc_path

GrapeSwaggerRails.options.before_action do
  GrapeSwaggerRails.options.app_url = request.protocol + request.host_with_port
end

