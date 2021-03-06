(import time)

;;;; some simple helpers

(defn assert-true [x]
  (assert (= True x)))

(defn assert-false [x]
  (assert (= False x)))

(defn assert-equal [x y]
  (assert (= x y)))

(defn test-cycle []
  "NATIVE: testing cycle"
  (assert-equal (list (cycle [])) [])
  (assert-equal (list (take 7 (cycle [1 2 3]))) [1 2 3 1 2 3 1])
  (assert-equal (list (take 2 (cycle [1 2 3]))) [1 2])
  (assert-equal (list (take 4 (cycle [1 None 3]))) [1 None 3 1]))

(defn test-dec []
  "NATIVE: testing the dec function"
  (assert-equal 0 (dec 1))
  (assert-equal -1 (dec 0))
  (assert-equal 0 (dec (dec 2)))
  (try (do (dec "foo") (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e)))))
  (try (do (dec []) (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e)))))
  (try (do (dec None) (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e))))))

(defn test-distinct []
  "NATIVE: testing the distinct function"
  (setv res (list (distinct [ 1 2 3 4 3 5 2 ])))
  (assert-equal res [1 2 3 4 5])
  ;; distinct of an empty list should be []
  (setv res (list (distinct [])))
  (assert-equal res [])
  ;; now with an iter
  (setv test_iter (iter [1 2 3 4 3 5 2]))
  (setv res (list (distinct test_iter)))
  (assert-equal res [1 2 3 4 5])
  ; make sure we can handle None in the list
  (setv res (list (distinct [1 2 3 2 5 None 3 4 None])))
  (assert-equal res [1 2 3 5 None 4]))

(defn test-drop []
  "NATIVE: testing drop function"
  (setv res (list (drop 2 [1 2 3 4 5])))
  (assert-equal res [3 4 5])
  (setv res (list (drop 3 (iter [1 2 3 4 5]))))
  (assert-equal res [4 5])
  (setv res (list (drop 3 (iter [1 2 3 None 4 5]))))
  (assert-equal res [None 4 5])
  (setv res (list (drop 0 [1 2 3 4 5])))
  (assert-equal res [1 2 3 4 5])
  (setv res (list (drop -1 [1 2 3 4 5])))
  (assert-equal res [1 2 3 4 5])
  (setv res (list (drop 6 (iter [1 2 3 4 5]))))
  (assert-equal res [])
  (setv res (list (take 5 (drop 2 (iterate inc 0)))))
  (assert-equal res [2 3 4 5 6]))

(defn test-even []
  "NATIVE: testing the even? function"
  (assert-true (even? -2))
  (assert-false (even? 1))
  (assert-true (even? 0))
  (try (even? "foo")
       (catch [e [TypeError]] (assert (in "not a number" (str e)))))
  (try (even? [])
       (catch [e [TypeError]] (assert (in "not a number" (str e)))))
  (try (even? None)
       (catch [e [TypeError]] (assert (in "not a number" (str e))))))

(defn test-filter []
  "NATIVE: testing the filter function"
  (setv res (list (filter pos? [ 1 2 3 -4 5])))
  (assert-equal res [ 1 2 3 5 ])
  ;; test with iter
  (setv res (list (filter pos? (iter [ 1 2 3 -4 5 -6]))))
  (assert-equal res [ 1 2 3 5])
  (setv res (list (filter neg? [ -1 -4 5 3 4])))
  (assert-false (= res [1 2]))
  ;; test with empty list
  (setv res (list (filter neg? [])))
  (assert-equal res [])
  ;; test with None in the list
  (setv res (list (filter even? (filter numeric? [1 2 None 3 4 None 4 6]))))
  (assert-equal res [2 4 4 6])
  (setv res (list (filter none? [1 2 None 3 4 None 4 6])))
  (assert-equal res [None None]))

(defn test-inc []
  "NATIVE: testing the inc function"
  (assert-equal 3 (inc 2))
  (assert-equal 0 (inc -1))
  (try (do (inc "foo") (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e)))))
  (try (do (inc []) (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e)))))
  (try (do (inc None) (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e))))))

(defn test-instance []
  "NATIVE: testing instance? function"
  (defclass Foo [object])
  (defclass Foo2 [object])
  (defclass Foo3 [Foo])
  (setv foo (Foo))
  (setv foo3 (Foo3))
  (assert-true (instance? Foo foo))
  (assert-false (instance? Foo2 foo))
  (assert-true (instance? Foo foo3))
  (assert-true (instance? float 1.0))
  (assert-true (instance? int 3))
  (assert-true (instance? str (str "hello"))))

(defn test-iterable []
  "NATIVE: testing iterable? function"
  ;; should work for a string
  (setv s (str "abcde"))
  (assert-true (iterable? s))
  ;; should work for unicode
  (setv u "hello")
  (assert-true (iterable? u))
  (assert-true (iterable? (iter u)))
  ;; should work for a list
  (setv l [1 2 3 4])
  (assert-true (iterable? l))
  (assert-true (iterable? (iter l)))
  ;; should work for a dict
  (setv d {:a 1 :b 2 :c 3})
  (assert-true (iterable? d))
  ;; should work for a tuple?
  (setv t (, 1 2 3 4))
  (assert-true (iterable? t))
  ;; should work for a generator
  (assert-true (iterable? (repeat 3)))
  ;; shouldn't work for an int
  (assert-false (iterable? 5)))

(defn test-iterate []
  "NATIVE: testing the iterate function"
  (setv res (list (take 5 (iterate inc 5))))
  (assert-equal res [5 6 7 8 9])
  (setv res (list (take 3 (iterate (fn [x] (* x x)) 5))))
  (assert-equal res [5 25 625])
  (setv f (take 4 (iterate inc 5)))
  (assert-equal (list f) [5 6 7 8]))

(defn test-iterator []
  "NATIVE: testing iterator? function"
  ;; should not work for a list
  (setv l [1 2 3 4])
  (assert-false (iterator? l))
  ;; should work for an iter over a list
  (setv i (iter [1 2 3 4]))
  (assert-true (iterator? i))
  ;; should not work for a dict
  (setv d {:a 1 :b 2 :c 3})
  (assert-false (iterator? d))
  ;; should not work for a tuple?
  (setv t (, 1 2 3 4))
  (assert-false (iterator? t))
  ;; should work for a generator
  (assert-true (iterator? (repeat 3)))
  ;; should not work for an int
  (assert-false (iterator? 5)))

(defn test-neg []
  "NATIVE: testing the neg? function"
  (assert-true (neg? -2))
  (assert-false (neg? 1))
  (assert-false (neg? 0))
  (try (do (neg? "foo") (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e)))))
  (try (do (neg? []) (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e)))))
  (try (do (neg? None) (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e))))))

(defn test-zero []
  "NATIVE: testing the zero? function"
  (assert-false (zero? -2))
  (assert-false (zero? 1))
  (assert-true (zero? 0))
  (try (do (zero? "foo") (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e)))))
  (try (do (zero? []) (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e)))))
  (try (do (zero? None) (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e))))))

(defn test-none []
  "NATIVE: testing for `is None`"
  (assert-true (none? None))
  (setv f None)
  (assert-true (none? f))
  (assert-false (none? 0))
  (assert-false (none? "")))

(defn test-nth []
  "NATIVE: testing the nth function"
  (assert-equal 2 (nth [1 2 4 7] 1))
  (assert-equal 7 (nth [1 2 4 7] 3))
  (assert-true (none? (nth [1 2 4 7] 5)))
  (assert-true (none? (nth [1 2 4 7] -1)))
  ;; now for iterators
  (assert-equal 2 (nth (iter [1 2 4 7]) 1))
  (assert-equal 7 (nth (iter [1 2 4 7]) 3))
  (assert-true  (none? (nth (iter [1 2 4 7]) -1)))
  (assert-equal 5 (nth (take 3 (drop 2 [1 2 3 4 5 6])) 2)))

(defn test-odd []
  "NATIVE: testing the odd? function"
  (assert-true (odd? -3))
  (assert-true (odd? 1))
  (assert-false (odd? 0))
  (try (do (odd? "foo") (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e)))))
  (try (do (odd? []) (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e)))))
  (try (do (odd? None) (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e))))))

(defn test-pos []
  "NATIVE: testing the pos? function"
  (assert-true (pos? 2))
  (assert-false (pos? -1))
  (assert-false (pos? 0))
  (try (do (pos? "foo") (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e)))))
  (try (do (pos? []) (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e)))))
  (try (do (pos? None) (assert False))
       (catch [e [TypeError]] (assert (in "not a number" (str e))))))

(defn test-remove []
  "NATIVE: testing the remove function"
  (setv r (list (remove odd? [1 2 3 4 5 6 7])))
  (assert-equal r [2 4 6])
  (assert-equal (list (remove even? [1 2 3 4 5])) [1 3 5])
  (assert-equal (list (remove neg? [1 2 3 4 5])) [1 2 3 4 5])
  (assert-equal (list (remove pos? [1 2 3 4 5])) [])
  ;; deal with embedded None
  (assert-equal (list (remove (fn [x] (not (numeric? x))) [1 2 None 3 None 4])) [1 2 3 4]))

(defn test-repeat []
  "NATIVE: testing repeat"
  (setv r (repeat 10))
  (assert-equal (list (take 5 r)) [10 10 10 10 10])
  (assert-equal (list (take 4 r)) [10 10 10 10])
  (setv r (repeat 10 3))
  (assert-equal (list r) [10 10 10]))

(defn test-repeatedly []
  "NATIVE: testing repeatedly"
  (setv r (repeatedly (fn [] (inc 4))))
  (assert-equal (list (take 5 r)) [5 5 5 5 5])
  (assert-equal (list (take 4 r)) [5 5 5 5])
  (assert-equal (list (take 6 r)) [5 5 5 5 5 5]))

(defn test-take []
  "NATIVE: testing the take function"
  (setv res (list (take 3 [1 2 3 4 5])))
  (assert-equal res [1 2 3])
  (setv res (list (take 4 (repeat "s"))))
  (assert-equal res ["s" "s" "s" "s"])
  (setv res (list (take 0 (repeat "s"))))
  (assert-equal res [])
  (setv res (list (take -1 (repeat "s"))))
  (assert-equal res [])
  (setv res (list (take 6 [1 2 None 4])))
  (assert-equal res [1 2 None 4]))

(defn test-take-nth []
  "NATIVE: testing the take-nth function"
  (setv res (list (take-nth 2 [1 2 3 4 5 6 7])))
  (assert-equal res [1 3 5 7])
  (setv res (list (take-nth 3 [1 2 3 4 5 6 7])))
  (assert-equal res [1 4 7])
  (setv res (list (take-nth 4 [1 2 3 4 5 6 7])))
  (assert-equal res [1 5])
  (setv res (list (take-nth 5 [1 2 3 4 5 6 7])))
  (assert-equal res [1 6])
  (setv res (list (take-nth 6 [1 2 3 4 5 6 7])))
  (assert-equal res [1 7])
  (setv res (list (take-nth 7 [1 2 3 4 5 6 7])))
  (assert-equal res [1])
  ;; what if there are None's in list
  (setv res (list (take-nth 2 [1 2 3 None 5 6])))
  (assert-equal res [1 3 5])
  (setv res (list (take-nth 3 [1 2 3 None 5 6])))
  (assert-equal res [1 None])
  ;; using 0 should raise ValueError
  (let [[passed false]]
    (try
     (setv res (list (take-nth 0 [1 2 3 4 5 6 7])))
     (catch [ValueError] (setv passed true)))
    (assert passed)))

(defn test-take-while []
  "NATIVE: testing the take-while function"
  (setv res (list (take-while pos? [ 1 2 3 -4 5])))
  (assert-equal res [1 2 3])
  (setv res (list (take-while neg? [ -1 -4 5 3 4])))
  (assert-false (= res [1 2]))
  (setv res (list (take-while none? [None None 1 2 3])))
  (assert-equal res [None None])
  (setv res (list (take-while (fn [x] (not (none? x))) [1 2 3 4 None 5 6 None 7])))
  (assert-equal res [1 2 3 4]))
