function geninds()
    founder = genfounder()

    indvect = Array(Individual{Float64},N)
    for i = 1:N
        indvect[i]= deepcopy(founder)
    end

    return indvect
end

function genpop{T}(inds::Vector{Individual{T}})
    Population(inds,
               deepcopy(inds[1]),
               erdos_renyi_graph(N,P,is_directed=false))
end

function genpop()
    inds = geninds()
    genpop(inds)
end


function update(me::Population)
    update(me.individuals)
    update(me.connectivity)
end


function update(me::AbstractGraph)

end

function save(pop::Population, fname::String)
    networks = zeros(G^2+1,N+1)
    networks[:,1] = [0.:G^2]
    networks[1,:] = [0.:N]
    for i = 1:N
        networks[2:end,i+1] = pop.individuals[i].network
    end
    f = writedlm(joinpath("data",fname), networks, '\t')
end
