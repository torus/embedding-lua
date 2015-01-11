function four_times(m)
   return m * 4
end

function n_times(n)
   return function(m)
             return m * n
          end
end
