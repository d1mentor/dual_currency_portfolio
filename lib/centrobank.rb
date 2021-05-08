class Centrobank
  attr_reader :vaults

  URL = 'https://www.cbr.ru/currency_base/daily/'

  def initialize(args)
    @vaults = args
    @vaults.delete('Букв. код')
  end

  def self.get_courses
    html = URI.open(URL)
    doc = Nokogiri::HTML(html)
    data = doc.css('.data')
    tbody = data.xpath('//tbody/tr')
    args = {}

    tbody.each do |tr|
      vault_char_code = tr.elements[1].content
      vault_name = tr.elements[3].content
      vault_count = tr.elements[2].content.to_i
      vault_course = tr.elements[4].content.to_f

      args[vault_char_code] = [vault_name, vault_count, vault_course]
    end

    new(args)
  end

  def to_list
    result_str = ''
    @vaults.each do |vault_char_code, info|
      result_str << " #{vault_char_code} - #{info[0]}\n"
    end
    result_str
  end

  def get_vault_data(vault_char_code)
    vault_name = @vaults[vault_char_code][0]
    vault_course = @vaults[vault_char_code][2] / @vaults[vault_char_code][1]

    vault = {
      'char_code' => vault_char_code,
      'name' => vault_name,
      'course' => vault_course.round(2)
    }
  end
end
