Extra Practice Problems
Contributed by Pavel Lepin and Charilaos Skiadas

Write a function |palindromic|palindromic that takes a list of numbers and evaluates to a list of numbers of the same length, where each element is obtained as follows: the first element should be the sum of the first and the last elements of the original list, the second one should be the sum of the second and second to last elements of the original list, etc. Example: |(palindromic (list 1 2 4 8))|(palindromic (list 1 2 4 8)) evaluates to |(list 9 6 6 9)|(list 9 6 6 9).
Define a stream |fibonacci|fibonacci, the first element of which is 0, the second one is 1, and each successive element is the sum of two immediately preceding elements.
Write a function |stream-until|stream-until that takes a function |f|f and a stream, and applies |f|f to the values of in succession until |f|f evaluates to |#f|#f.
Write a function |stream-map|stream-map that takes a function |f|f and a stream, and returns a new stream whose values are the result of applying |f|f to the values produced by.
Write a function |stream-zip|stream-zip that takes in two streams |s1|s1 and |s2|s2 and returns a stream that produces the pairs that result from the other two streams (so the first value for the result stream will be the pair of the first value of |s1|s1 and the first value of |s2|s2).
Thought experiment: Why can you not write a function |stream-reverse|stream-reverse that is like Racket's |reverse|reverse function for lists but works on streams.
Write a function |interleave|interleave that takes a list of streams and produces a new stream that takes one element from each stream in sequence. So it will first produce the first value of the first stream, then the first value of the second stream and so on, and it will go back to the first stream when it reaches the end of the list. Try to do this without ever adding an element to the end of a list.
Define a function |pack|pack that takes an integer  and a stream, and returns a stream that produces the same values as but packed in lists of  elements. So the first value of the new stream will be the list consisting of the first  values of, the second value of the new stream will contain the next $|n|$$ values, and so on.
We'll use Newton's Method for approximating the square root of a number, but by producing a stream of ever-better approximations so that clients can "decide later" how approximate a result they want: Write a function |sqrt-stream|sqrt-stream that takes a number , starts with  as an initial guess in the stream, and produces successive guesses applying f_n(x)=\frac{1}{2}((x+\frac{n}{x})f 
n
​	
 (x)= 
2
1
​	
 ((x+ 
x
n
​	
 ) to the current guess.
Now use |sqrt-stream|sqrt-stream from the previous problem to define a function |approx-sqrt|approx-sqrt that takes two numbers  and |e|e and returns a number xx such that x\cdot xx⋅x is within |e|e of . Be sure not to create more than one stream nor ask for the same value from the stream more than once. Note: Because Racket defaults to fully precise rational values, you may wish to use a floating-point number for  (e.g., 10.0 instead of 10) as well as for |e|e.
Write a macro perform that has the following two forms:
|(perform e1 if e2)|(perform e1 if e2)

|(perform e1 unless e2)|(perform e1 unless e2)

|e1|e1 should be evaluated (once) depending on the result of evaluating |e2|e2 -- only if |e2|e2 evaluates to |#f|#f in the latter case, and only if it doesn't in the former case. If |e1|e1 is never evaluated, the entire expression should evaluate to |e2|e2. Neither |e1|e1 nor |e2|e2 should be evaluated more than once in any case.