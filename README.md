# bash-merge-microservice-repos-to-one
Merge git repositories of microservices into one, where each microservice is in directory
#

###Example usage:
    
    Repositories: a b c
    bash mergeRepos.sh https://github.com/user/a.git https://github.com/user/b.git https://github.com/user/c.git
    
1.Clone each repo

2.Move each repo content to new directory (with name of this directory)

3.Merge b and c to a (with git history) on master branch

a) Only master is merged, other branches for b and c, are not merged
    
    
Output directories:
    
    -a
     |-- a
         | --content1
         | --content23353445t
     |-- b
         | --file1
         | --dir
         | --Main.java
         | --Kurka.py
         | --content1
         | --content23353445t              
     |-- c
         | --cat.png
         | --contnt23353445t
         | --contt1
         | --content23353445t
         

#
Tested for 6 repositories from Bitbucket.com, on ubuntu
