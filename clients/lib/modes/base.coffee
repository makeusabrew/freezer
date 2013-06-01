class BaseMode
    getSnapshot: (request) -> throw "getSnapshot must be re-defined"

module.exports = BaseMode
