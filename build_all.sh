cd ./bgsave
source gvp
gpm
go install bgsave
sudo docker build -t xtaci/bgsave .
cd ..

cd ./snowflake
source gvp
gpm
go install snowflake
sudo docker build -t xtaci/snowflake .
cd ..

cd ./geoip
source gvp
gpm
go install geoip
sudo docker build -t xtaci/geoip .
cd ..

cd ./wordfilter
source gvp
gpm
go install wordfilter
sudo docker build -t xtaci/wordfilter .
cd ..
