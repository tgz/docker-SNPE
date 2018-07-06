# Docker image For SNPE

Docker image for

[SNPE](https://developer.qualcomm.com/docs/snpe/setup.html) `Snapdragon Neural Processing Engine SDK` 

# Usage

## build
	
	docker build -t snpe .
	
## Run
	
	docker run -it -v ~/Git/snpe-1.13.0:/snpe --name=snpe snpe
	
