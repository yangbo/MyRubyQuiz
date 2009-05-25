#!/usr/local/bin/ruby
# == Salitaire cryphor
# Quiz url: http://www.rubyquiz.com/quiz1.html
class Salitaire
   def encrypt message
      preprocessed_msg = preprocess message
      keys = keystream preprocessed_msg
      puts "keys: #{keys}"
      msg_nums = letter_to_int preprocessed_msg
      key_nums = letter_to_int keys
      index = 0
      result_nums = msg_nums.collect do |n|
         sum = key_nums[index]+n
         sum -= 26 if sum > 26
         index += 1
         sum
      end
      every_5 int_to_letter result_nums
   end

   def decrypt message
      key_nums = letter_to_int(keystream(message))
      msg_nums = letter_to_int message
      decode_nums = []
      msg_nums.each_with_index do |n, idx|
         n+=26 if n <= key_nums[idx]
         decode_nums << n-key_nums[idx]
      end
      every_5 int_to_letter decode_nums
   end

   def every_5 msg
      splited = ""
      msg.chars.each_with_index do |c, idx|
         splited << c
         splited << " " if idx >= 4 and (idx+1)%5==0
      end
      splited.upcase
   end

   # Discard any non A to Z characters, and uppercase all remaining letters.
   # Split the message into five character groups, using Xs to pad the last group, if needed.
   def preprocess orig_msg
      filterd_msg = orig_msg.chars.reject do |c|
         c =~ /[^a-zA-Z]/
      end
      msg = filterd_msg.to_s
      msg += "X"* (5 - (filterd_msg.size+5) % 5) if (filterd_msg.size+5)%5 != 0
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
      keys = ""
      deck = DECK.clone
      msg.size.times do
         char, deck = generate_char! deck
         keys += char
      end
      keys
   end

   # The original deck is like 1..52 A B.
   # 1. Move the A joker down one card.
   # 2. Move the B joker down two cards.
   # 3. Perform a triple cut around the two jokers.
   # 4. Perform a count cut using the value of the bottom card.
   # 5. Find the output letter.
   # return: char, modified deck
   def generate_char! deck
      move_forward deck, :A, 1
      move_forward deck, :B, 2
      min, max = [deck.index(:A), deck.index(:B)].sort
      new_deck = deck[max+1..-1] + deck[min..max] + deck[0...min]
      # count cut
      count = new_deck.last
      deck = new_deck[count..-2] + new_deck[0...count] + [new_deck.last]
      out_char = 0
      if [:A, :B].include? deck.first
         out_char = deck[53]
      else
         out_char = deck[deck.first]
      end
      if [:A, :B].include? out_char
         generate_char! deck
      else
         [int_to_letter([out_char]).first, deck]
      end
   end

   def move_forward deck, card, num
      idx = deck.index card
      if idx + num >= deck.size
         insert_idx = num - (deck.size-1-idx)
         deck.delete_at idx
         deck.insert insert_idx, card
      else
         deck.insert idx+num+1, card
         deck.delete_at idx
      end
   end

   # all characters of msg should be upper case or blank char.
   # A->1, B->2
   def letter_to_int msg
      msg.delete(" ").chars.collect do |c|
         c[0] - "A"[0] + 1
      end
   end

   # 1->A, 2->B
   # 27->1->A
   def int_to_letter nums
      str = " "*nums.size
      idx=0
      nums.collect do |n|
         n -= 26 if n > 26
         str[idx] = ?A + n - 1
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
   #
   #enc = salitaire.encrypt "CODE IN RUBY LIVE LONGER!"
   #dec = salitaire.decrypt enc
   #puts "enc: #{enc}, dec: #{dec}"
   #puts salitaire.encrypt "welcome to ru world!"
   #puts salitaire.generate_char! Salitaire::DECK
   puts salitaire.decrypt "CLEPK HHNIY CFPWH FDFEH"
   puts salitaire.decrypt "ABVAW LWZSY OORYK DUPVH"
end
