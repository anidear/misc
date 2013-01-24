#!/usr/bin/env ruby

#define .prime? method
class Fixnum
	def prime?
		return false if self<2
		(2..Math.sqrt(self).round).each{|i| return false if self%i==0}
		return true
	end
end

puts "Generate two prime numbers:"
#p = Random.rand(100..10000)
#q = Random.rand(100..10000)
p = Random.rand(1..100)
q = Random.rand(1..100)
puts "p = #{p}"
puts "q = #{q}"

puts 
puts "These two prime numbers multiplied together will generate 'n' value."
puts "This 'n' value will be used as 'mod n' later."
n = p*q
puts "n = #{n}"

puts 
puts "Now, we will generate public and private keys."
puts "Public key: is used for distributed publicly. It has two purposes:"
puts "\t1) Let other people know that the message is from us, only if "
puts "\t   the message can be decrypted with our public key."
puts "\t2) Let other people ensure that their sent message is only for us to read."
puts "\t   The messages must be encrypted with this public key."
puts 
puts "First, we'll calculate for a modulo value."
puts "This modulo value is calculated from (p-1).(q-1)"
mod = (p-1)*(q-1)
puts "It is (#{p}-1).(#{q}-1)=#{mod}"
puts
puts "Then, get a list of 'prime numbers' that is a 'relatively prime' with the modulo value."
puts "Note that: relatively prime numbers of #{mod} are numbers that cannot devide #{mod}."
relatively_prime_list = (1..mod).select{|i| i.prime? and mod%i!=0}
puts "They are: #{relatively_prime_list.first(5).join(', ')}...#{relatively_prime_list.last(5).join(', ')}"
puts
puts "Then we pick one from the list and that will be our 'public key'"
public_key = relatively_prime_list.sample(1)
puts "public key = #{public_key}"
puts
puts "Next thing to do is to find a private key that can unlock the public key."
puts "This method is derived from Fermat's Little Theorem that says:"
puts "\t if p is a prime number, then a^(p-1) = 1 (mod p) for all a"
puts "\t this can be converted to:   a^p = a (mod p) ; if p is prime"
puts "\t for example, p=1373, a=90..100: "
puts "\t\t a^p= "+(90..100).map{|i|i**1373 %1373}.join(', ')
puts
puts "Imagine as 'a' is our data, a number in plain-text, that we want to send"
puts "and 'p' is our encrypt-then-decrypt process."
puts "If we encrypt the data then decrypt it, it must result in the same data."
puts
puts "Since 'p' is only one number, but represents 2 processes inside (encrypt,decrypt)."
puts "It is not good. We need a way to separate the number 'p' into 2 numbers."
puts 
puts "But how can we separate a prime number into 2 numbers? ... We cannot!"
puts ""

