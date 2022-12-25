#include <fstream>
#include <algorithm>
#include <iostream>
#include "inc/utils.h"

using mindspore::MSTensor;
using mindspore::DataType;

std::vector<std::string> GetAllFiles(std::string_view dirName) {
  struct dirent *filename;
  DIR *dir = OpenDir(dirName);
  if (dir == nullptr) {
    return {};
  }
  std::vector<std::string> res;
  while ((filename = readdir(dir)) != nullptr) {
    std::string dName = std::string(filename->d_name);
    if (dName == "." || dName == ".." || filename->d_type != DT_REG) {
      continue;
    }
    res.emplace_back(std::string(dirName) + "/" + filename->d_name);
  }
  std::sort(res.begin(), res.end());
  for (auto &f : res) {
    std::cout << "Text file: " << f << std::endl;
  }
  return res;
}

int WriteResult(const std::string& textFile, const std::vector<MSTensor> &outputs) {
  std::vector<std::string> homePath;
  homePath.push_back("./result_files/result_00");
  homePath.push_back("./result_files/result_01");
  homePath.push_back("./result_files/result_02");
  homePath.push_back("./result_files/result_03");
  homePath.push_back("./result_files/result_04");
  homePath.push_back("./result_files/result_05");
  for (size_t i = 0; i < outputs.size(); ++i) {
    size_t outputSize;
    std::shared_ptr<const void> netOutput;
    netOutput = outputs[i].Data();
    outputSize = outputs[i].DataSize();
    int pos = textFile.rfind('/');
    std::string fileName(textFile, pos + 1);
    std::string outFileName = homePath[i] + "/" + fileName;
    FILE * outputFile = fopen(outFileName.c_str(), "wb");
    fwrite(netOutput.get(), outputSize, sizeof(char), outputFile);
    fclose(outputFile);
    outputFile = nullptr;
  }
  return 0;
}

mindspore::MSTensor ReadFileToTensor(const std::string &file) {
  if (file.empty()) {
    std::cout << "Pointer file is nullptr" << std::endl;
    return mindspore::MSTensor();
  }

  std::ifstream ifs(file);
  if (!ifs.good()) {
    std::cout << "File: " << file << " is not exist" << std::endl;
    return mindspore::MSTensor();
  }

  if (!ifs.is_open()) {
    std::cout << "File: " << file << "open failed" << std::endl;
    return mindspore::MSTensor();
  }

  ifs.seekg(0, std::ios::end);
  size_t size = ifs.tellg();
  mindspore::MSTensor buffer(file, mindspore::DataType::kNumberTypeUInt8, {static_cast<int64_t>(size)}, nullptr, size);

  ifs.seekg(0, std::ios::beg);
  ifs.read(reinterpret_cast<char *>(buffer.MutableData()), size);
  ifs.close();

  return buffer;
}


DIR *OpenDir(std::string_view dirName) {
  if (dirName.empty()) {
    std::cout << " dirName is null ! " << std::endl;
    return nullptr;
  }
  std::string realPath = RealPath(dirName);
  struct stat s;
  lstat(realPath.c_str(), &s);
  if (!S_ISDIR(s.st_mode)) {
    std::cout << "dirName is not a valid directory !" << std::endl;
    return nullptr;
  }
  DIR *dir;
  dir = opendir(realPath.c_str());
  if (dir == nullptr) {
    std::cout << "Can not open dir " << dirName << std::endl;
    return nullptr;
  }
  std::cout << "Successfully opened the dir " << dirName << std::endl;
  return dir;
}

std::string RealPath(std::string_view path) {
  char realPathMem[PATH_MAX] = {0};
  char *realPathRet = nullptr;
  realPathRet = realpath(path.data(), realPathMem);

  if (realPathRet == nullptr) {
    std::cout << "File: " << path << " is not exist.";
    return "";
  }

  std::string realPath(realPathMem);
  std::cout << path << " realpath is: " << realPath << std::endl;
  return realPath;
}
