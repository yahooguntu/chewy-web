module Chewy::Web
  module RenderUtils
    def cluster_health_label(status)
      level = case status
              when 'green' then :success
              when 'yellow' then :warning
              when 'red' then :error
              end
      label(status, level)
    end

    def label(text, level)
      "<span class=\"label label-#{level}\">#{text}</span>".html_safe
    end

    def status_text(alert:, red:, green:)
      "<span class=\"#{alert ? 'red' : 'green'}\">#{alert ? red : green}</span>".html_safe
    end

    def status_td(alert:, red:, green:)
      "<td class=\"#{alert ? 'red' : 'green'}\">#{alert ? red : green}</td>".html_safe
    end

    def duration(seconds)
      seconds = seconds.to_i
      minutes, seconds = seconds.divmod(60)
      hours, minutes = minutes.divmod(60)

      "#{hours.to_s.rjust(2)}h #{minutes.to_s.rjust(2)}m #{seconds}s"
    end

    def format_status(status)
      color = status.starts_with?("Success") ? 'success': 'error'

      "<span class=\"text-#{color}\">#{status}</span>".html_safe
    end

    def number_with_delimiter(num)
      num.to_s.reverse.scan(/.{1,3}/).join(',').reverse
    end

    def button_to(name, url, options = {})
      button_html = ''

      method = (options.delete(:method) || 'get').downcase
      klass = options.delete(:class)
      disabled = options.delete(:disabled) == true
      data = options.delete(:data)

      if method != 'get' && method != 'post'
        button_html += "<input name=\"_method\" value=\"#{method}\" type=\"hidden\" />"
        method = 'post'
      end

      button_html += "<input value=\"#{name}\" type=\"submit\""
      button_html += " class=\"#{klass}\"" if klass
      button_html += ' disabled="disabled"' if disabled
      button_html += " #{data_attrs(data)}" if data
      button_html += " />"



      "<form class=\"button_to\" method=\"#{method}\" action=\"#{url}\">#{button_html}</form>"
    end

    private

    def data_attrs(hash)
      hash.map do |name, val|
        "data-#{name}=\"#{val}\""
      end.join(' ')
    end

  end
end
