#!/bin/zsh

cd ~/Projects/plsql/3GB/plsql-md-doc
node app cours_TAPI
cp ~/Projects/plsql/3GB/cours/md/* ~/Projects/plsql/3GB/mkdocs/cours_TAPI/docs/
cd ~/Projects/plsql/3GB/mkdocs/cours_TAPI/
mkdocs build
mkdocs serve
# open http://127.0.0.1:8000/ dans votre navigateur web
