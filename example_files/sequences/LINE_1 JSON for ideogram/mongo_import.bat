for %%f in (*.json) do (
    "C:\Program Files\MongoDB\Server\3.6\bin\mongoimport.exe" --db retrodb --collection seqview1 --file %%~nf.json
)