ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  if html_tag.sub!(/class="/, 'class=" inputText-error ').nil?
    html_tag.sub! /(\/?>)/, ' class=" inputText-error"\1'
  end
  if instance.error_message.kind_of?(Array)
    instance.error_message.each do |error_message|
      html_tag += %(<p><span class="text-validationError">#{error_message}</span></p>)
    end
  else
    html_tag = %(#{html_tag}<p><span class="text-validationError">#{instance.error_message}</span></p>)
  end
  html_tag.html_safe
end