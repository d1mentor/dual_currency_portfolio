if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

require 'open-uri'
require 'nokogiri'
require 'net/http'

URL = 'https://www.cbr.ru/currency_base/daily/'
VAULT_CHAR_CODE = 'USD'

def get_course(vault_char_code)
  html = URI.open(URL)
  doc = Nokogiri::HTML(html)
  data = doc.css('.data')
  tbody = data.xpath('//tbody/tr')

  tbody.each do |tr|
    vault_count = tr.elements[2].content.to_i
    vault_course = tr.elements[4].content.to_f / vault_count

    if tr.elements[1].content == vault_char_code
      return vault_course
    end
  end
end

def calculate(rub, vault, course)
  difference = ((rub - vault * course) / 2).round(2)

  return 0 if difference.abs <= 0.1
  difference
end

begin
  course = get_course(VAULT_CHAR_CODE)
rescue
  print 'Невозможно получить курс из сети, введите вручную:'
  course = gets.to_f
end

print 'Сколько у вас RUB:'
rub_count = gets.to_f
print "Сколько у вас #{VAULT_CHAR_CODE}:"
vault_count = gets.to_f

result = calculate(rub_count, vault_count, course)

case result
when 0
  puts 'Портфель сбалансирован!'
when (0.02..)
  puts "Вам надо купить #{(result / course).round(2)} #{VAULT_CHAR_CODE}"
else
  puts "Вам надо купить #{result.abs} RUB"
end
