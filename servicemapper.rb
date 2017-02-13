require 'active_support/time'
require 'uri'
require 'net/http'
require 'openssl'
#require 'ruby-jq'
require 'json'
require 'pry'

#-------------
# Pull list of all repos (paginated)
#-------------

repourl = ""
baseurl = ""
parsed_owners = "blah"
owners = "blah"
MAX_PAGES = 45
n = 0
l = 0

while n < MAX_PAGES
	
	url = URI("#{baseurl}" + "#{n}")

	http = Net::HTTP.new(url.host, url.port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE

	request = Net::HTTP::Get.new(url) 
	request["authorization"] = ''
	request["cache-control"] = 'no-cache'

	#-------------
	# Parse pulled data / names of every repo
	#-------------

	repos = http.request(request)
	parsed_repos = JSON.parse(repos.body)
	paginate_length = parsed_repos.length
	#puts paginate_length

	while l < paginate_length
		#puts "page number is #{n} , repo number is #{l}"
		#---all repos----
		#reponame = parsed_repos[l]
		reponame = parsed_repos[l]["name"]
		# puts "\n========START REPO========="
		# puts reponame

		ownerurl = URI("#{repourl}" + "#{reponame}" + "/contributors")
		request = Net::HTTP::Get.new(ownerurl)
		owners = http.request(request)
		
		#puts "#{reponame}: parsed_owners ==> #{owners.body}..."
		
		l += 1

		unless owners.body.nil?
			parsed_owners = JSON.parse(owners.body)
			#binding.pry
			#puts "Not found" if parsed_owners[0]["message"].downcase == "not found"
			# accounting for occasional GitHub bloop
			if parsed_owners.is_a?(Array) && !parsed_owners[0]["login"].nil?
				#puts parsed_owners
				ownername = parsed_owners[0]["login"]
				puts "#{reponame} #{ownername}"
			
			else
				puts "unable to pull value"
				puts "#{reponame} \n"

				# binding.pry if reponame == "deploymacy"
				#ownername = parsed_owners[l][2]["login"]
				#puts ownername
			end
				# puts "======END OF REPO=========\N"
				# puts ownername
				#---repos whose last push was more than 1yr ago---
				#pr = parsed_repos[l]["pushed_at"] 
				#if pr =~ /2013(.*)/
				#	puts parsed_repos[l]["name"]
				#end
		end 
	end

	n += 1
	l = 0

end
