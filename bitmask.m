byteB = [1 1 1 1 1 1 1 1];
byteA = [0 0 0 0 0 0 0 0];

bitword = fliplr([byteA byteB])

index = (length(bitword):-1:1) -1 

p2 = power(2, index)

word = sum(p2)