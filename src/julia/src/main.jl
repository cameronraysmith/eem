using Graphs
using Distributions
using Datetime
using DataFrames
#using Gadfly
#using Debug

#-------------------------
# setup
#-------------------------

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
configpath = joinpath(indir,configfile)
run(`cp $configpath $simdir`)

plotspdf = joinpath(simdir,"plots.pdf")
netspdf = joinpath(simdir,"nets.pdf")

#-------------------------
# run simulation
#-------------------------

pop  = genpop()
meas = genmeasure()

save(pop,joinpath(simdir,netsname(0)))
measnum = 1
tpb=textprogressbar("running grn evolution: ",[])
for t=1:GENS
    update(pop)
    if (mod(t-1,MEASPERIOD)==0) | (t==GENS)
        measure(pop,meas,t,measnum)
        measnum += 1
    end
    if (mod(t-1,CLUSTPERIOD)==0) | (t==GENS)
        save(pop,joinpath(simdir,netsname(t)))
    end
    tpb=textprogressbar(t/GENS*100,tpb)
end
textprogressbar(" done.",tpb)

df = save(meas,joinpath(simdir,"sim.csv"))

#-------------------------
# plot results
#-------------------------

# Gadfly not working...
#p1 = plot(df, x="time", y="pathlength", Geom.point)
#draw(PDF(joinpath(simdir,"myplot.pdf"), 6inch, 3inch), p1)

# Python script substitutes for Gadfly to plot basic data
plotxvar = "time"
plotyvar = ["fitness","pathlength","indtypes","develtypes"]
plotspdfs = map(x->joinpath(simdir,string(x,".pdf")),plotyvar)

run(`python plotdata.py -d $simdir -x $plotxvar -y $plotyvar`)
run(`gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=$plotspdf
        -dBATCH $plotspdfs`)

nettsvs = map(x->chomp(joinpath(simdir,x)),
              readlines(`ls $simdir` |> `grep nets` |> `grep .tsv`))
netpdfs = map(x->replace(x,".tsv",".pdf"),nettsvs)
pmap(clustergram,nettsvs)
run(`gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=$netspdf
        -dBATCH $netpdfs`)

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

#run(`evince $simdir\/nets.pdf $simdir\/$plotyvar\.pdf`)
run(`evince $netspdf $plotspdf`)
run(`libreoffice $simdir\/sim.csv`)
