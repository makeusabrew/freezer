module.exports =
    formatJSON: (data, spaces = 2) -> JSON.stringify JSON.parse(data), null, spaces
