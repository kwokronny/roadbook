import fs from 'fs'
import path from 'path'
import { pinyin } from "pinyin-pro"

function changeFileName(filename) {
  filename = filename.replace(/[0-9a-f]{32}/gi, '')
  return pinyin(filename, { toneType: 'none' })
    .replace(/[^A-Za-z0-9-\s_]/g, '')// 移除非字母、数字和短横线的字符
    .trim()
    .toLowerCase() // 将字符串转换为小写
    .replace(/\s+/g, '-') // 替换空格为短横线

}

const folderPathMap = new Map()

/**
 * 遍历文件夹内的所有文件和文件夹
 * @param {string} folderPath 文件夹路径
 */
function traverseFolder(folderPath) {
  const files = fs.readdirSync(folderPath);
  files.forEach(file => {
    const filePath = path.join(folderPath, file);
    const stats = fs.statSync(filePath);
    if (stats.isDirectory()) {
      // 如果是文件夹，递归遍历
      const newFileName = changeFileName(file); // 替换掉 guid 字符
      const newFilePath = path.join(folderPath, newFileName)
      // newFileName
      folderPathMap.set(newFileName, file)
      fs.renameSync(filePath, newFilePath);
      console.log(`已重命名文件夹：${file} -> ${newFileName}`);
      traverseFolder(path.join(folderPath, newFileName));
    } else if (file.lastIndexOf('.md') > -1) {
      // 如果是文件，重命名
      const [name, ext] = file.split('.')
      const newFileName = [changeFileName(name), ext].join('.'); // 替换掉 guid 字符
      fs.renameSync(filePath, path.join(folderPath, newFileName));
      console.log(`已重命名文件：${file} -> ${newFileName}`);
    }
  });
}

function traverseMarkdownPath(folderPath) {
  const files = fs.readdirSync(folderPath);
  files.forEach(file => {
    const filePath = path.join(folderPath, file);
    const stats = fs.statSync(filePath);
    if (stats.isDirectory()) {
      traverseMarkdownPath(filePath);
    } else if (file.lastIndexOf('.md') > -1) {
      let markdown = fs.readFileSync(filePath, { encoding: 'utf-8' })
      folderPathMap.forEach((value, key) => {
        // console.log(new RegExp(encodeURI(value), 'ig'), encodeURI(key))
        markdown = markdown.replace(new RegExp(encodeURI(value), 'ig'), encodeURI(key))
      })
      fs.writeFileSync(filePath, markdown, { encoding: 'utf-8' })
    }
  });
}




// 使用示例
const targetFolderPath = 'src'; // 替换为你的目标文件夹路径
traverseFolder(targetFolderPath);
// 将引用的图片链接更新
traverseMarkdownPath(targetFolderPath)
