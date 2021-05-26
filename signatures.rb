class FelFlame
  class Signature
    class <<self
      def next_signature
        @next_signature ||= 1
      end

      def next_signature= num
        @next_signature = num
      end

      def create_new_signature(name)
        temp = self.next_signature
        self.next_signature = 2 * self.next_signature
        define_singleton_method(name) do
          temp
        end
        send(name)
      end
    end
  end
end
