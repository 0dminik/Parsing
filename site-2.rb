require 'open-uri'
require 'nokogiri'
require 'csv'

#Start Page
url = 'http://www.petsonic.com/es/perros/snacks-y-huesos-perro'
html = open(url)
doc = Nokogiri::HTML(html)

#Get all pages from paginator
pages = doc.xpath(".//ul[@class='pagination pull-left']/li/a")
linkpage = []
linkpage.push(url) #added current page
pages.each do |page|
  linkpage.push('http://www.petsonic.com' + page['href'])
end
linkpage = linkpage.slice(0, linkpage.size - 1)

#Create CSV document
CSV.open("final.csv","w") do |wr|
linkpage.each do |pageurl|
  url = pageurl
  html = open(url)
  doc = Nokogiri::HTML(html)

  #Get all product links from current page
  links = doc.xpath(".//a[@class='product_img_link']") # Get all product links on the current page
  linkUrls = []
  links.each do |link|
    linkUrls.push(link['href'])
  end
  i = 0
  #Check to empty array
  if !linkUrls.nil?
    linkUrls.each do |urlItem|
      #Get current product
      html = open(urlItem)
      productDOC = Nokogiri::HTML(html)

      #Image
      img = productDOC.xpath(".//img[@id='bigpic']")
      image = img.first['src']

      #Name
      tagName = productDOC.xpath(".//h1[@itemprop='name']")
      tagName.search(".//span").remove
      name = tagName.text #.gsub(/[^\x00-\x7F]/n,'')

      nam = productDOC.xpath(".//ul[@class='attribute_labels_lists']")

      a = ''
      b = ''
      if !nam.nil?
        nam.each do |namies|
          a = a + namies.xpath(".//span[@class='attribute_name']").text
          b = b + namies.xpath(".//span[@class='attribute_price']").text.strip
          #puts "#{a} #{b}"
        end
      end

      puts urlItem
      puts image
      puts name
      puts a
      puts b

      #Write row to file
      wr << [ urlItem,image,name, a, b]
    end
  end
end
end

puts "Complete!"

