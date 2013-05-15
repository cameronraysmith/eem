import sys
import matplotlib.pyplot as plt
import numpy as np
import scipy.stats as sps
import sqlite3 as sqlite

## parameter values

# binary flags
plotreal = 0
plotend = 1
randenv = 0
saveplot = 1
showplot = 0

sys.argv = 0
# parameters constructing the space to characterize
if sys.argv < 1:
    ampsize = 2 # amplitude of fluctuations
    P = 4 # period 
    ssmix = 0.9 # square / sinusoid mixing proportion    
elif sys.argv < 2:
    P = 4 # period 
    ssmix = 0.9 # square / sinusoid mixing proportion
elif sys.argv < 3:
    ssmix = 0.9 # square / sinusoid mixing proportion
else:
	print "incorrect number of input arguments"

mutrate = .1
mutmag = [0.05, 0.05]

popsize = 1000
k = 1

# stable parameters
maxtime = 10**5 # 10^5/2 is a good runtime
tS = 0.2 # time step

time = np.linspace(1,tS*maxtime,num=maxtime)

if randenv:
    # Env = ampsize.*(round(rand(length(time),1)').*2 - 1)
    Env = ampsize*np.round(np.random.uniform(low=-2, high=2,size=maxtime))
else:
    Env1 = ampsize*(-1)**(np.round(time/P))
    Env2 = ampsize*np.cos(time*(np.pi/P))
    Env = ssmix*Env1 + (1-ssmix)*Env2

Pop = np.zeros((popsize,3))

Pop[0][0] = 1 #isogenic initial pop
Pop[0][1] = 0 #center at mean
Pop[0][2] = 0.1 #stddev

avggen = np.zeros((maxtime,1))

extinct = 0.001
newstrain = 0.01

## time loop

for i in range(maxtime):
  
    #Population growth
    temp3 = np.nonzero(Pop[:,0] != 0)[0]
    Pop[temp3][:,0] = Pop[temp3][:,0]*\
                      np.exp(\
                      (sps.norm.pdf(Env[i],Pop[temp3][:,1],Pop[temp3][:,2]))/\
                      (sps.norm.pdf(0,0,Pop[temp3][:,2]))*\
                      (k/(Pop[temp3][:,2]**2+k)))
    Pop[:,0] = Pop[:,0]/np.sum(Pop[:,0])
    
    #Calculate average stdev
    avggen[i] = np.sum(Pop[:,0]*Pop[:,2])

    #extinction
    Pop[Pop[:,0]<extinct] = 0
        
    #Mutation
    if (np.sum(Pop[:,0]!=0) < popsize and	
        	np.random.uniform() < mutrate):
        temp = np.nonzero(Pop[:,0]>0)[0]
        newmut = np.random.permutation(np.sum(Pop[:,0]>0))
        temp2 = np.nonzero(Pop[:,0] == 0)[0]
        Pop[temp2[0]][0] = newstrain
        Pop[temp2[0]][1] = mutmag[0]*np.random.randn()+Pop[temp[newmut[0]]][1]
        Pop[temp2[0]][2] = np.abs(mutmag[1]*np.random.randn()+Pop[temp[newmut[0]]][2])
#     if rem(i,1000) == 0
#         figure(1)
#         bar(sort(Pop(:,1),'descend'))
#     end

#     if plotreal
#     if rem(i,1000) == 0
#         figure(1)
# #        bar(sort(Pop(:,1),'descend'))
#         [varS,I] = sort(Pop(:,3))
#         stem(varS(varS~=0),Pop(I(varS~=0),1))
#     end
#     end        
if plotend:
    # figure(2)
    fig1 = plt.figure(1)
    f1p1 = plt.plot(avggen,linestyle='none',marker='o',mec='r',mfc='r')
    
    if saveplot:
        plt.savefig('fig/avggen')
    
    if showplot:
        plt.show()
    
    # figure(3)
    fig2 = plt.figure(2)
    I = np.argsort(Pop[:,2])
    f2p1 = plt.stem(Pop[I,2], Pop[I,0], linefmt='b-', markerfmt='bo', basefmt='r-')
    
    if saveplot:
        plt.savefig('fig/stem')

    if showplot:
        plt.show()
    
    # figure(4)
    fig3 = plt.figure(3)
    f3p1 = plt.plot(Env[1:50],linestyle='none',marker='o',mec='k',mfc='k')
    if saveplot:
        plt.savefig('fig/envshort')

    if showplot:
        plt.show()

    # figure(5)
    fig4 = plt.figure(4)
    f4p1 = plt.plot(Env,linestyle='none',marker='o',mec='k',mfc='k')
    if saveplot:
        plt.savefig('fig/envlong')

    if showplot:
        plt.show()
