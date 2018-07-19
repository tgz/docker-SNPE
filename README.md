# Docker image For SNPE

Docker image for

[SNPE](https://developer.qualcomm.com/docs/snpe/setup.html) `Snapdragon Neural Processing Engine SDK` 

with caffe & adb

# Usage

  
## build

```bash
	docker build -t snpe .
```
	
## Run
```bash
	docker run -it  --privileged -v ~/Git/snpe-1.13.0:/root/snpe -v /dev/bus/usb:/dev/bus/usb --name=snpe snpe
```

## 将 `caffemodel` 转换为 `dlc`
   
```bash
        # First time run
        # 将 clone 下来的 snpe 仓库挂载至 docker 镜像的 `/root/snpe`
        docker run -it -v ~/Git/snpe:/root/snpe --name=snpe_dev docker.zerozero.cn/snpe

        # 之后启动此 Docker Container 只需要：
        docker start -i snpe_dev

        # 上一步完成后，自动进入 Docker 的交互式环境，直接开始转换 caffemodel，生成的dlc默认在当前目录
        snpe-caffe-to-dlc -b xxx.caffemodel -c xxx.prototxt
```

## benchmark 
    
在 SNPE SDK 目录下，有 `benchmarks` 文件夹

用法：    
```python
    python snpe_bench.py -c bench_config.json -a -t le
```
   
   bechmark 相关参数，可以参照该目录下的 json 文件
    