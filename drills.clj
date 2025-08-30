(def all-drills
  [
   [{:name "1mm", :diameter 0.03937007874015748, :length 1.3385826771653544, :bin-columns 2}
    {:name "#60", :diameter 0.04, :length 13/8, :bin-columns 2}
    {:name "#59", :diameter 0.041, :length 13/8, :bin-columns 2}
    {:name "#58", :diameter 0.042, :length 13/8, :bin-columns 2}
    {:name "#57", :diameter 0.043, :length 7/4, :bin-columns 2}]

   [{:name ["#56" "3/64"], :diameter 0.0465, :length 7/4, :bin-columns 2}
    {:name "#55", :diameter 0.052, :length 15/8, :bin-columns 2}
    {:name "#54", :diameter 0.055, :length 15/8, :bin-columns 2}
    {:name ["1.5mm" "#53"], :diameter 0.05905511811023623, :length 1.5748031496062993} ;;??
    {:name "1/16", :diameter 0.0625, :length 3, :bin-columns 2}]

   [{:name "#52", :diameter 0.0635, :length 15/8, :bin-columns 2}
    {:name "#51", :diameter 0.067, :length 2, :bin-columns 2}
    {:name "#50", :diameter 0.07, :length 2, :bin-columns 2}
    {:name "#49", :diameter 0.073, :length 2, :bin-columns 2}
    {:name "#48", :diameter 0.076, :length 2, :bin-columns 2}]

   [{:name "5/64", :diameter 0.078125, :length 15/4, :bin-columns 3}
    {:name ["#47" "2mm"] :diameter 0.0785, :length 2, :bin-columns 2}
    {:name "#46", :diameter 0.081, :length 17/8, :bin-columns 2}
    {:name "#45", :diameter 0.082, :length 17/8, :bin-columns 2}
    {:name "#44", :diameter 0.086, :length 17/8, :bin-columns 2}]

   [{:name "#43", :diameter 0.089, :length 9/4, :bin-columns 2}
    {:name ["#42" "3/32"], :diameter 0.0935, :length 9/4, :bin-columns 2}
    {:name "#41", :diameter 0.096, :length 19/8, :bin-columns 2}
    {:name ["#40" "2.5mm"], :diameter 0.098, :length 19/8, :bin-columns 2}
    {:name "#39", :diameter 0.0995, :length 19/8, :bin-columns 2}]

   [{:name "#38", :diameter 0.1015, :length 5/2, :bin-columns 2}
    {:name "#37", :diameter 0.104, :length 5/2, :bin-columns 2}
    {:name "#36", :diameter 0.1065, :length 5/2, :bin-columns 2}
    {:name "7/64", :diameter 0.109375, :length 37/8, :bin-columns 3}
    {:name "#35", :diameter 0.11, :length 21/8, :bin-columns 2}]

   [{:name "#34", :diameter 0.111, :length 21/8, :bin-columns 2}
    {:name "#33", :diameter 0.113, :length 21/8, :bin-columns 2}
    {:name "#32", :diameter 0.116, :length 11/4, :bin-columns 2}
    {:name "3mm", :diameter 0.11811023622047245, :length 2.4015748031496065, :bin-columns 2}
    {:name "#31", :diameter 0.12, :length 11/4, :bin-columns 2}]

   [{:name ["1/8" "3.2mm"], :diameter 0.125, :length 41/8, :bin-columns 4}
    {:name "#30", :diameter 0.1285, :length 11/4, :bin-columns 2}
    {:name "#29", :diameter 0.136, :length 23/8, :bin-columns 2}
    {:name "3.5mm", :diameter 0.1377952755905512, :length 2.7559055118110236, :bin-columns 2}]

   ;;9
   [{:name ["#28" "9/64"], :diameter 0.1405, :length 23/8, :bin-columns 2}
    {:name "#27", :diameter 0.144, :length 3, :bin-columns 2}
    {:name "#26", :diameter 0.147, :length 3, :bin-columns 2}
    {:name "#25", :diameter 0.1495, :length 3, :bin-columns 2}]

   ;;10
   [{:name "#24", :diameter 0.152, :length 25/8, :bin-columns 3}
    {:name "#23", :diameter 0.154, :length 25/8, :bin-columns 3}
    {:name "5/32", :diameter 0.15625, :length 43/8, :bin-columns 4}
    {:name "#22, 4mm", :diameter 0.157, :length 3.5, :bin-columns 3}]

   ;; 11
   [{:name "#21", :diameter 0.159, :length 13/4, :bin-columns 3}
    {:name "#20", :diameter 0.161, :length 13/4, :bin-columns 3}
    {:name "#19", :diameter 0.166, :length 13/4, :bin-columns 3}
    {:name "#18", :diameter 0.1695, :length 13/4, :bin-columns 3}]

   ;; 12
   [{:name "11/64", :diameter 0.171875, :length 23/4, :bin-columns 4}
    {:name "#17", :diameter 0.173, :length 27/8, :bin-columns 3}
    {:name "#16", :diameter 0.177, :length 27/8, :bin-columns 3}
    {:name "4.5mm", :diameter 0.17716535433070868, :length 3.1496062992125986}] ;;?

   ;; 13
   [{:name "#15", :diameter 0.18, :length 27/8, :bin-columns 3}
    {:name "#14", :diameter 0.182, :length 27/8, :bin-columns 3}
    {:name "#13", :diameter 0.185, :length 7/2, :bin-columns 3}
    {:name "3/16", :diameter 0.1875, :length 23/4, :bin-columns 4}]

   ;; 14
   [{:name "#12", :diameter 0.189, :length 7/2, :bin-columns 3} ;; 4.8mm
    {:name "#11", :diameter 0.191, :length 7/2, :bin-columns 3}
    {:name "#10", :diameter 0.1935, :length 29/8, :bin-columns 3}
    {:name "#9, 5mm", :diameter 0.196, :length 3.625, :bin-columns 3}]

   {:name "#8", :diameter 0.199, :length 29/8, :bin-columns 3}
   {:name "#7", :diameter 0.201, :length 29/8, :bin-columns 3}
   {:name "13/64", :diameter 0.203125, :length 6, :bin-columns 4}
   {:name "#6", :diameter 0.204, :length 15/4, :bin-columns 3}

   {:name "#5", :diameter 0.2055, :length 15/4, :bin-columns 3}
   {:name "#4", :diameter 0.209, :length 15/4, :bin-columns 3}
   {:name "#3", :diameter 0.213, :length 15/4, :bin-columns 3}
   {:name "5.5mm", :diameter 0.21653543307086615, :length 3.661417322834646}

   {:name "7/32", :diameter 0.21875, :length 6, :bin-columns 4}
   {:name "#2", :diameter 0.221, :length 31/8, :bin-columns 3}
   {:name "#1", :diameter 0.228, :length 31/8, :bin-columns 3}
   {:name "A, 15/64", :diameter 0.234, :length 31/8, :bin-columns 3}

   {:name "6mm", :diameter 0.2362204724409449, :length 3.661417322834646, :bin-columns 3}
   {:name "B", :diameter 0.238, :length 4, :bin-columns 3}
   {:name "C", :diameter 0.242, :length 4, :bin-columns 3}
   {:name "D", :diameter 0.246, :length 4, :bin-columns 3}

   [{:name "E, 1/4", :diameter 0.25, :length 4, :bin-columns 3}
    {:name "6.5mm", :diameter 0.2559055118110236, :length 3.9763779527559056}
    {:name "F", :diameter 0.257, :length 33/8, :bin-columns 3}
    {:name "G", :diameter 0.261, :length 33/8, :bin-columns 3}]

   [{:name "H, 17/64", :diameter 0.265625, :length 25/4, :bin-columns 4}
    {:name "I", :diameter 0.272, :length 33/8, :bin-columns 3}
    {:name "7mm", :diameter 0.2755905511811024, :length 4.291338582677166, :bin-columns 3}
    {:name "J", :diameter 0.277, :length 33/8, :bin-columns 3}]

   [{:name "K, 9/32", :diameter 0.281, :length 17/4, :bin-columns 4}
    {:name "L", :diameter 0.29, :length 17/4, :bin-columns 3}
    {:name "M", :diameter 0.295, :length 35/8, :bin-columns 3}
    {:name "7.5mm", :diameter 0.29527559055118113, :length 4.291338582677166}]

   [{:name "19/64", :diameter 0.296875, :length 51/8, :bin-columns 5}
    {:name "N", :diameter 0.302, :length 35/8, :bin-columns 3}
    {:name "5/16", :diameter 0.3125, :length 51/8, :bin-columns 5}
    {:name "8mm", :diameter 0.31496062992125984, :length 4.606299212598426, :bin-columns 3}]

   [{:name "O", :diameter 0.316, :length 9/2, :bin-columns 3}
    {:name "P", :diameter 0.323, :length 37/8, :bin-columns 3}
    {:name "21/64", :diameter 0.328125, :length 13/2, :bin-columns 5}
    {:name "Q", :diameter 0.332, :length 19/4, :bin-columns 4}]

   ;;
   [{:name "8.5mm", :diameter 0.3346456692913386, :length 4.606299212598426}
    {:name "R", :diameter 0.339, :length 19/4, :bin-columns 4}
    {:name "11/32", :diameter 0.34375, :length 13/2, :bin-columns 5}]

   ;;
   [{:name "S", :diameter 0.348, :length 39/8, :bin-columns 4}
    {:name "9mm", :diameter 0.35433070866141736, :length 4.921259842519685, :bin-columns 4}
    {:name "T", :diameter 0.358, :length 39/8, :bin-columns 4}]

   ;;
   [{:name "23/64", :diameter 0.359375, :length 27/4, :bin-columns 5}
    {:name "U", :diameter 0.368, :length 5, :bin-columns 4}
    {:name "9.5mm", :diameter 0.37401574803149606, :length 4.921259842519685}]

   [{:name "3/8", :diameter 0.375, :length 27/4, :bin-columns 5}
    {:name "V", :diameter 0.377, :length 5, :bin-columns 4}
    {:name "W", :diameter 0.386, :length 41/8, :bin-columns 4}]

   [{:name "25/64", :diameter 0.390625, :length 7, :bin-columns 5}
    {:name "10mm", :diameter 0.3937007874015748, :length 5.236220472440945, :bin-columns 4}
    {:name "X", :diameter 0.397, :length 41/8, :bin-columns 4}]

   [{:name "Y", :diameter 0.404, :length 21/4, :bin-columns 4}
    {:name "13/32", :diameter 0.40625, :length 7, :bin-columns 5}
    {:name "Z", :diameter 0.413, :length 21/4, :bin-columns 4}]

   [{:name "10.5mm", :diameter 0.4133858267716536, :length 5.236220472440945}
    {:name "27/64", :diameter 0.421875, :length 29/4, :bin-columns 5}]

   [{:name "11mm", :diameter 0.4330708661417323, :length 5.590551181102363, :bin-columns 5}
    {:name "7/16", :diameter 0.4375, :length 29/4, :bin-columns 5}]

   [{:name "11.5mm", :diameter 0.45275590551181105, :length 5.590551181102363}
    {:name "29/64", :diameter 0.453125, :length 15/2, :bin-columns 5}]
   ;; 1x5

   [{:name "15/32", :diameter 0.46875, :length 15/2, :bin-columns 5}
    {:name "12mm", :diameter 0.4724409448818898, :length 5.94488188976378, :bin-columns 5}
    {:name "31/64", :diameter 0.484375, :length 31/4, :bin-columns 5}]

   ;; 2x
   [{:name "12.5mm", :diameter 0.4921259842519685, :length 5.94488188976378}
    {:name "1/2", :diameter 0.5, :length 31/4, :bin-columns 5}
    {:name "13mm", :diameter 0.5118110236220472, :length 5.94488188976378, :bin-columns 5}]])

(println (->> all-drills (map :bin-columns) (reduce +)))
