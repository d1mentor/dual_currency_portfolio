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
require_relative 'lib/centrobank'

bank = Centrobank.get_courses

puts 'Валюта №1 по умолчанию - RUB'
puts 'Необходимо выбрать вторую валюту.'

puts bank.to_list
user_choice = ''

loop do
  print 'Введите буквенный код валюты:'
  user_choice = gets.chomp.upcase

  if bank.vaults.key?(user_choice)
    break
  else
    puts 'Некорректный ввод! Попробуйте еще раз.'
  end
end

second_vault = bank.get_vault_data(user_choice)

puts "\nПараметры текущего портфеля:"
puts "Валюты: RUB(рубли) - #{second_vault['char_code']}(#{second_vault['name']})"
puts "Текущий курс: #{second_vault['course']} RUB = 1 #{second_vault['char_code']}"

puts 'Вводите целое число, при некорректном вводе, по умолчанию установится 0'
print 'Сколько у вас RUB:'
rub_count = gets.to_i
print "Сколько у вас #{second_vault['char_code']}:"
second_vault_count = gets.to_i

rub_in_second_vault = rub_count / second_vault['course']
second_vault_in_rub = second_vault_count * second_vault['course']
dif = rub_in_second_vault - second_vault_count

# Проверяем не сбалансирован ли портфель
if dif.abs <= 0.01
  puts 'Ваш портфель уже сбалансирован'
  # Если Рублей больше
elsif rub_in_second_vault > second_vault_count
  # Считаем разницу
  # Разницу делим на 2 потому что покупаем за свои деньги
  difference = ((rub_in_second_vault - second_vault_count) / 2).round(2)
  puts "Вам надо купить #{second_vault['char_code']} #{difference}"
else
  # Если второй валюты больше, все аналогично только в другую сторону)
  difference = ((second_vault_in_rub - rub_count) / 2).round(2)
  puts "Вам надо купить RUB #{difference}"
end
