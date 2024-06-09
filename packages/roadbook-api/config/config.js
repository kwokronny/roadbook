const path = require("path");
const fs = require("fs")
let sercet = 'H4nVbpvGCC2Urum3iwbd2UVcHTNhzmNBtg8yDMQnx98T38crvmjtwZ6obiAp8yNSVnYqnon5HrQXP'
if (fs.existsSync('storage/jwt.pub')) {
  sercet = fs.readFileSync("storage/jwt.pub")
}
module.exports = {
  sercet,
  uploadDir: path.resolve("storage/public/uploads"),
};
