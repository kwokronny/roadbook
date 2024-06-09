module.exports = {
  parseJSON(JSONStr) {
    try {
      return JSON.parse(JSONStr)
    } catch {
      return null
    }
  },
  ajaxReturn(dataOrmsg, code) {
    code = code || 200;
    if (code == 200) {
      return { code, data: dataOrmsg, msg: "Success" };
    } else {
      if (dataOrmsg.code && dataOrmsg.code === 'INVALID_PARAM') {
        console.log(dataOrmsg)
        dataOrmsg = '传参不正确，请检查'
      }
      return { code, msg: dataOrmsg };
    }
  },
  pageWrapper(record, page, pageSize, total) {
    return {
      record,
      page,
      pageSize,
      total,
    };
  },
};
