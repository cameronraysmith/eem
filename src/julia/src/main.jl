using Graphs
using Distributions
using Datetime
using DataFrames
using Gadfly
#using Debug

configfile = "constants.jl"
#configfile = "constants_test.jl"
#configfile = "constants_bergsieg2002.jl"
indir = joinpath("..","input")
outdir = joinpath("..","output")
require(joinpath(indir,configfile))

require("utilities.jl")
require("types.jl")
require("modularity.jl")
require("individuals.jl")
require("population.jl")
require("textprogressbar.jl")
require("measure.jl")

timestamp = gentimestamp()

simdir = joinpath(outdir,timestamp)
run(`mkdir $simdir`)
run(`cp $indir\/$configfile $simdir`)

pop  = genpop()
meas = genmeasure()
save(pop,joinpath(simdir,"initnets.tsv"))

tpb=textprogressbar("running grn evolution: ",[])
for t=1:GENS
    update(pop)
    measure(pop,meas,t)
    tpb=textprogressbar(t/GENS*100,tpb)
end
textprogressbar(" done.",tpb)

save(pop,joinpath(simdir,"finalnets.tsv"))
df = save(meas,joinpath(simdir,"sim.csv"))

#-------------------------
# plot data
#-------------------------

# Gadfly not working...
#p1 = plot(df, x="time", y="pathlength", Geom.point)
#draw(PDF(joinpath(simdir,"myplot.pdf"), 6inch, 3inch), p1)

# Python script substitutes for Gadfly to plot basic data
plotxvar = "time"
plotyvar = "pathlength"
run(`python plotdata.py -d $simdir\/sim.csv -o $simdir\/$plotyvar\.pdf -x $plotxvar -y $plotyvar`)

#save(pop,"nets_g$G\_n$N\_c$C\_t$GENS\.tsv")
#save(meas,"sim_g$G\_n$N\_c$C\_t$GENS\.csv")

# Make clustergrams of population
run(`python clustergram.py --i $simdir\/initnets.tsv`)
run(`python clustergram.py --i $simdir\/finalnets.tsv`)

println("\nSample Final Individuals from Population:")
println("===========================================\n")
println(pop.individuals[1:5])
println("\nPopulation Founder:")
println("===========================================\n")
println(pop.founder)
println("\nConnectivity of Population:")
println("===========================================\n")
println(pop.connectivity)
println("\nNumber of non-zeros in founder:")
println("===========================================\n")
println(length(find(pop.founder.network)))
println("\nAverage number of non-zeros in final pop:")
println("===========================================\n")
println(mean(map(x -> length(find(x.network)), pop.individuals)))
println()

run(`evince $simdir\/initnets.pdf $simdir\/finalnets.pdf $simdir\/$plotyvar\.pdf`)
