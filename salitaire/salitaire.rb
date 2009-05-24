#!/usr/local/bin/ruby
# == Salitaire cryphor
# Quiz url: http://www.rubyquiz.com/quiz1.html
class Salitaire
   def encrypt message
      preprocessed_msg = preprocess message
      keys = keystream preprocessed_msg
      msg_nums = letter_to_int preprocessed_msg
      key_nums = letter_to_int keys
      index = 0
      result_nums = msg_nums.collect do |n|
         sum = key_nums[index]+n
         sum -= 26 if sum > 26
         index += 1
         sum
      end
      int_to_letter result_nums
   end

   def decrypt message
      key_nums = letter_to_int(keystream(message))
      msg_nums = letter_to_int message
      decode_nums = []
      msg_nums.each_with_index do |n, idx|
         n+=26 if n <= key_nums[idx]
         decode_nums << n-key_nums[idx]
      end
      int_to_letter decode_nums
   end

   # Discard any non A to Z characters, and uppercase all remaining letters.
   # Split the message into five character groups, using Xs to pad the last group, if needed.
   def preprocess orig_msg
      filterd_msg = orig_msg.chars.reject do |c|
         c =~ /[^a-zA-Z]/
      end
      msg = filterd_msg.to_s
      msg += "X"* (5 - (filterd_msg.size+5) % 5) if (filterd_msg.size+5)%5 != 0
=begin
      splited = ""
      msg.chars.each_with_index do |c, idx|
         splited << c
         splited << " " if idx >= 4 and (idx+1)%5==0
      end
      splited.upcase
=end
      msg.upcase
   end

   # cards face value as a base, Ace = 1, 2 = 2... 10 = 10, Jack = 11, Queen = 12, King = 13.
   # Clubs is simply the base value, Diamonds is base value + 13,
   # Hearts is base value + 26, and Spades is base value + 39. Either joker values at 53.
   #
   # When the cards must represent a letter Clubs and Diamonds values are taken to be
   # the number of the letter (1 to 26), as are Hearts and Spades after subtracting 26
   # from their value (27 to 52 drops to 1 to 26).
   DECK = (1..52).to_a+[:A, :B]
   def keystream msg
      keys = " " * msg.size
      deck = DECK.clone
      msg.size.each do
         keys += generate_char! deck
      end
   end

   # 1. Move the A joker down one card.
   # 2. Move the B joker down two cards.
   # 3. Perform a triple cut around the two jokers.
   # 4. Perform a count cut using the value of the bottom card.
   # 5. Find the output letter.
   def generate_char! deck
   end

   # all characters of msg should be upper case or blank char.
   # A->1, B->2
   def letter_to_int msg
      msg.delete(" ").chars.collect do |c|
         c[0] - "A"[0] + 1
      end
   end

   # 1->A, 2->B
   def int_to_letter nums
      str = " "*nums.size
      idx=0
      nums.collect do |n|
         str[idx] = ?A+n-1
         idx+=1
      end
      str
   end
end


if __FILE__ == $0
   salitaire = Salitaire.new
   #puts salitaire.letter_to_int "CODEI NRUBY LIVEL ONGER"
   #puts salitaire.preprocess "hello salitaire world!"
   #puts salitaire.preprocess "hello salitaire world a!"
   enc = salitaire.encrypt "CODEINRUBYLIVELONGER"
   dec = salitaire.decrypt enc
   puts "enc: #{enc}, dec: #{dec}"
   #puts salitaire.encrypt "welcome to ru world!"
end
