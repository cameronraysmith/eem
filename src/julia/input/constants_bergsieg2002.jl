# parameters
const G=10 # number of genes per individual, default 10, small 3
const N=500 # population size, default 500, small 10
const C=0.75 # connectivity probability for individuals (Gaussian matrices)
const GENS=1000 # total number of generations, default 400, small 10
const MAXCONV=100 # max number of iterations to test for convergence
const MUTRATE=0.1 # mutation rate used in MUTRATE/(cG^2)
const MUTMAG=1 # magnitude of mutations
const SELSTR=1 # selection strength aka \sigma, highest selection when close to 0 no selection as SELSTR approaches infinity
const ROBIT=10 # number of iterations to run in robustness testing
const P=0.5 # connectivity probability for population structure graph
const TAU=10 # look-behind depth for convergence testing with sigmoidal function, default 10
const INP1=[] # if empty, the intial state of the founder is generated at random
const OPT1=[]
const INP2=[]
const OPT2=[]
const SWITCHSTART=GENS-0 # If less than GENS, start switching between INP1/OPT1 and INP2/OPT2, otherwise remain on INP1/OPT1
const FRACMEAS = 15/GENS
const MEASPERIOD = convert(Int64,round(1/FRACMEAS))
const NUMMEAS = convert(Int64,round(GENS/MEASPERIOD) + 1)
const FRACCLUST = 10/GENS
const CLUSTPERIOD = convert(Int64,round(1/FRACCLUST))
const NUMCLUST = convert(Int64,round(GENS/CLUSTPERIOD) + 2)

# flags
const RANDPOP=false # if true generate initial population with random interactions rather than a homogeneous one
const SEXUALREPRO=true # if true interleave rows from two individuals each generation
const MEASUREFIT=true # measure fitness
const MEASUREROBUST=true # measure robustness
const MEASUREMOD=true # measure modularity
const PROGBAR=true # if true show progressbar
const PLOTFLAG=false # if true, produce and show plots after running simulation
const INDWEIGHTS="gaussian" # if "discrete" then sample {1,-1,0} via rand(-1:1) if "gaussian" use randn()
