using LinearAlgebra
using Printf

str(v,s)  = join(map(i -> i ? "|"*s : "0"*s , v))
print_key(k) = for i in 1:size(k)[begin] print(str(k[i,:]," "),"\n") end
print_vec(v) = print(str(v,""),"\n")
key(n) = rand(Bool,n,n)

spin_row(k,i) = circshift(k[i,:], k[i,i]  + 1)
spin_col(k,i) = circshift(k[:,i], k[i,i]  + 1)

# spin!(k,i) =for j in 1:size(k)[begin] Bool((j+i)%2) ? k[j,:] = spin_row(k,j) : k[:,j] = spin_col(k,j) end
rgb(r,g,b) =  "\e[38;2;$(r);$(g);$(b)m"

red() = rgb(255,0,0);yellow() = rgb(255,255,0);white() = rgb(255,255,255);gray(h) = rgb(h,h,h)
blue() = rgb(0,0,255);

# function spin(q,p)
#     k = copy(q)
#     for j in 1:n[begin]
#         if  Bool((j+p)%2) 
#             k[j,:] = spin_row(k, j, p)
#         else 
#             k[:,j] = spin_col(k, j, p)
#         end
#     end
#     k
# end

function encode(p,q)
    k = copy(q)
    c = Bool[]
    for i in eachindex(p)
        push!(c,Bool((tr(k) + p[i])%2))
        if  Bool(p[i]) 
            k[mod1(i,n),:] = spin_row(k,mod1(i,n))
        else 
            k[:,mod1(i,n)] = spin_col(k,mod1(i,n))
        end
    end
    c
end

function decode(c,q)
    k = copy(q)
    p = Bool[]
    for i in eachindex(c)
        push!(p,Bool((tr(k) + c[i])%2))
        if  Bool(p[i]) 
            k[mod1(i,n),:] = spin_row(k,mod1(i,n))
        else 
            k[:,mod1(i,n)] = spin_col(k,mod1(i,n))
        end
    end
    p
end

function autospin(q,c)
    k = copy(q)
    for i in 1:n Bool(q[i,c]) ? k[i,:] = spin_row(k,i) : k[:,i] = spin_col(k,i) end
    k
end

function self(q)
    k = copy(q)
    for i in 1:n k[i,:] = encrypt(q[i,:],q,n) end
    k
end

function encrypt(p, q, r)
    for i in 1:r
        k = autospin(q, mod1(i,n))
        p = encode(p,k)
        p = reverse(p)
    end
    p
end


function decrypt(p, q, r)
    for i in 1:r
        k = autospin(q,mod1(r + 1 - i,n))
        p = reverse(p)
        p = decode(p,k)
    end
    p
end

function demo()
    print(white(),"k =\n", gray(150))
    print_key(k)
    print("\n",white(),"r = \n",gray(150),r,"\n\n")
    for i in 1:w
    	p = rand(Bool,t)
        print(white(),"f( ", red(), str(p,""), white()," ) = ")
        c  = encrypt(p,k,r)
        print(yellow(),str(c,""), "    ")
        e = p .== c
        print(gray(100),str(e,""), " \n")
        d  = decrypt(c,k,r)
        if p != d @printf "ERROR" end 	
    end
    print(white())
end

function long_demo()
    print(white(),"k =\n", gray(150))
    print_key(k)
    print("\n",white(),"r = \n",gray(150),r,"\n\n")
    for i in 1:w
    	p = rand(Bool,t)
        print( red(), str(p,""), "\n")
        c  = encrypt(p,k,r)
        print( yellow(), str(c,""), "\n")
        e = p .!= c
        print(gray(100),str(e,""), " \n\n")
        d  = decrypt(c,k,r)
        if p != d @printf "\nERROR\n" end 	
    end
    print(white())
end
function key_eating_demo()
    q = copy(k)
    print(white(),"k =\n", gray(150))
    print_key(k)
    for i in 1:n
    	p = k[i,:]
        print(white(),"f( ", red(), str(p,""), white()," ) = ")
        c  = encrypt(p,k,r)
        q[i,:] = c
        print(yellow(),str(c,""), "  ")
        e = p .== c
        print(gray(100),str(e,""), " \n")
        d  = decrypt(c,k,r)
        if p != d @printf "ERROR" end 	
    end
    print("\n")
    print(white(),"q =\n", gray(150))
    print_key(q)
    for i in 1:n
    	p = q[i,:]
        print(white(),"f( ", red(), str(p,""), white()," ) = ")
        c  = encrypt(p,q,r)
        k[i,:] = c
        print(yellow(),str(c,""), "  ")
        e = p .== c
        print(gray(100),str(e,""), " \n")
        d  = decrypt(c,q,r)
        if p != d @printf "ERROR" end 	
    end
    print(white())
end

function key_eating_demo_2()
    q = copy(k)
    for _ in 1:4
        for i in 1:n
            p = k[i,:]
            print(white(),"f( ", red(), str(p," "), white()," ) = ")
            c  = encrypt(p,k,r)
            q[i,:] = c
            print(yellow(),str(c," "), "  ")
            e = p .== c
            print(gray(100),str(e," "), " \n")
            d  = decrypt(c,k,r)
            if p != d @printf "ERROR" end 	
        end
        print("\n")
        for i in 1:n
            p = q[i,:]
            print(white(),"f( ", red(), str(p," "), white()," ) = ")
            c  = encrypt(p,q,r)
            k[i,:] = c
            print(yellow(),str(c," "), "  ")
            e = p .== c
            print(gray(100),str(e," "), " \n")
            d  = decrypt(c,q,r)
            if p != d @printf "ERROR" end 	
        end
        print("\n")
    end
    print(white())
end

function self_demo(k)
    for i in 1:n
        print_key(k)
        print("\n")
        k =  self(k)
    end
end

n = 8
r = n
k = key(n)
t = 128
w = 4
self_demo(k)