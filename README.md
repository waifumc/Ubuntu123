# Ubuntu123

```
# Clone the repository
git clone https://github.com/Snhvn/Ubuntu123
cd Ubuntu123

# Build the Docker image
docker build -t ubuntu-vm .

# Run the container
docker run --privileged -p 6080:6080 -p 2221:2222 -v $PWD/vmdata:/data ubuntu-vm
```
