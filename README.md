### How to 

#### 1- Create a 4store dump 
```
sudo 4s-dump http://localhost:8081/sparql/ -a -o ./data
```

#### 2- Convert the 4store dump to Virtuoso dump 
```
./4s-to-virtuoso.sh ./data .
```
#### 3- Import the Virtuoso dump 
```
./import_to_virtuoso.sh <virtuoso_user> <virtuoso_pwd> "./processed_files"
```

#### 4- Check if the triple count corresponds to the count in the dump files 
```
ruby compare_counts.rb
```

will generate a csv called `graph_comparaison.csv`
