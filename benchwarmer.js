"use strict";
function _array_like_to_array(arr, len) {
    if (len == null || len > arr.length) len = arr.length;
    for(var i = 0, arr2 = new Array(len); i < len; i++)arr2[i] = arr[i];
    return arr2;
}
function _array_without_holes(arr) {
    if (Array.isArray(arr)) return _array_like_to_array(arr);
}
function _class_call_check(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
        throw new TypeError("Cannot call a class as a function");
    }
}
function _defineProperties(target, props) {
    for(var i = 0; i < props.length; i++){
        var descriptor = props[i];
        descriptor.enumerable = descriptor.enumerable || false;
        descriptor.configurable = true;
        if ("value" in descriptor) descriptor.writable = true;
        Object.defineProperty(target, descriptor.key, descriptor);
    }
}
function _create_class(Constructor, protoProps, staticProps) {
    if (protoProps) _defineProperties(Constructor.prototype, protoProps);
    if (staticProps) _defineProperties(Constructor, staticProps);
    return Constructor;
}
function _iterable_to_array(iter) {
    if (typeof Symbol !== "undefined" && iter[Symbol.iterator] != null || iter["@@iterator"] != null) return Array.from(iter);
}
function _non_iterable_spread() {
    throw new TypeError("Invalid attempt to spread non-iterable instance.\\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.");
}
function _to_consumable_array(arr) {
    return _array_without_holes(arr) || _iterable_to_array(arr) || _unsupported_iterable_to_array(arr) || _non_iterable_spread();
}
function _unsupported_iterable_to_array(o, minLen) {
    if (!o) return;
    if (typeof o === "string") return _array_like_to_array(o, minLen);
    var n = Object.prototype.toString.call(o).slice(8, -1);
    if (n === "Object" && o.constructor) n = o.constructor.name;
    if (n === "Map" || n === "Set") return Array.from(n);
    if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _array_like_to_array(o, minLen);
}
// package.json
var version = "1.2.0";
var author = "Tom Scott <tubbo@psychedeli.ca>";
var license = "MIT";
// add.ts
function Add(settings) {
    var _loop = function(y2) {
        var _loop = function(x) {
            var elements = map.getTile(x, y2).elements;
            var surface = elements.filter(function(element) {
                return element.type === "surface";
            })[0];
            var footpaths = elements.filter(function(element) {
                return element.type === "footpath";
            });
            footpaths.forEach(function(path) {
                if (canBuildAdditionOnPath(surface, path)) {
                    if (path.isQueue) {
                        paths.queues.push({
                            path: path,
                            x: x,
                            y: y2
                        });
                    } else if ((path === null || path === void 0 ? void 0 : path.slopeDirection) === null) {
                        paths.unsloped.push({
                            path: path,
                            x: x,
                            y: y2
                        });
                    } else {
                        paths.sloped.push({
                            path: path,
                            x: x,
                            y: y2
                        });
                    }
                }
            });
        };
        for(var x = 0; x < map.size.x; x++)_loop(x);
    };
    var paths = {
        unsloped: [],
        sloped: [],
        queues: []
    };
    for(var y2 = 0; y2 < map.size.y; y2++)_loop(y2);
    paths.unsloped.forEach(function(param) {
        var path = param.path, x = param.x, y2 = param.y;
        var bench = settings.bench, bin = settings.bin;
        var addition = findAddition(bench, bin, x, y2);
        ensureHasAddition(x, y2, path.baseZ, addition);
    });
    paths.sloped.forEach(function(param) {
        var path = param.path, x = param.x, y2 = param.y;
        var buildBinsOnAllSlopedPaths = settings.buildBinsOnAllSlopedPaths;
        var evenTile = x % 2 === y2 % 2;
        var buildOnSlopedPath = buildBinsOnAllSlopedPaths || evenTile;
        if (buildOnSlopedPath) {
            ensureHasAddition(x, y2, path.baseZ, settings.bin);
        }
    });
    paths.queues.forEach(function(param) {
        var path = param.path, x = param.x, y2 = param.y;
        ensureHasAddition(x, y2, path.baseZ, settings.queuetv);
    });
    return paths;
}
function ensureHasAddition(x, y2, z, addition) {
    context.executeAction("footpathadditionplace", {
        // x/y coords need to be multiples of 32
        x: x * 32,
        y: y2 * 32,
        z: z,
        object: addition
    }, function(param) {
        var errorTitle = param.errorTitle, errorMessage = param.errorMessage;
        if (errorMessage) throw new Error("".concat(errorTitle, ": ").concat(errorMessage));
    });
}
function findAddition(bench, bin, x, y2) {
    if (x % 2 === y2 % 2) {
        return bench;
    } else {
        return bin;
    }
}
function canBuildAdditionOnPath(surface, path) {
    if (!surface || !path) return false;
    if (path.addition !== null) return false;
    if (surface.hasOwnership) return true;
    if (surface.hasConstructionRights && surface.baseHeight !== path.baseHeight) {
        return true;
    }
    return false;
}
// settings.ts
var BENCH = "Benchwarmer.Bench";
var BIN = "Benchwarmer.Bin";
var QUEUETV = "Benchwarmer.QueueTV";
var BUILD = "Benchwarmer.BuildOnAllSlopedFootpaths";
var PRESERVE = "Benchwarmer.PreserveOtherAdditions";
var AS_YOU_GO = "Benchwarmer.BuildAsYouGo";
var Settings = /*#__PURE__*/ function() {
    function Settings(all) {
        _class_call_check(this, Settings);
        this.benches = all.filter(function(a) {
            return a.identifier.includes("bench");
        });
        this.bins = all.filter(function(a) {
            return a.identifier.includes("litter");
        });
        this.queuetvs = all.filter(function(a) {
            return a.identifier.includes("qtv");
        });
    }
    _create_class(Settings, [
        {
            key: "bench",
            get: function get() {
                return this.benches[this.selections.bench].index;
            },
            set: function set(index) {
                context.sharedStorage.set(BENCH, index);
            }
        },
        {
            key: "bin",
            get: function get() {
                var _this_bins_this_selections_bin;
                return (_this_bins_this_selections_bin = this.bins[this.selections.bin]) === null || _this_bins_this_selections_bin === void 0 ? void 0 : _this_bins_this_selections_bin.index;
            },
            set: function set(index) {
                context.sharedStorage.set(BIN, index);
            }
        },
        {
            key: "queuetv",
            get: function get() {
                var _this_queuetvs_this_selections_queuetv;
                return (_this_queuetvs_this_selections_queuetv = this.queuetvs[this.selections.queuetv]) === null || _this_queuetvs_this_selections_queuetv === void 0 ? void 0 : _this_queuetvs_this_selections_queuetv.index;
            },
            set: function set(index) {
                context.sharedStorage.set(QUEUETV, index);
            }
        },
        {
            key: "selections",
            get: function get() {
                var bench = context.sharedStorage.get(BENCH, 0);
                var bin = context.sharedStorage.get(BIN, 0);
                var queuetv = context.sharedStorage.get(QUEUETV, 0);
                return {
                    bench: bench,
                    bin: bin,
                    queuetv: queuetv
                };
            }
        },
        {
            key: "buildBinsOnAllSlopedPaths",
            get: function get() {
                return context.sharedStorage.get(BUILD, false);
            },
            set: function set(value) {
                context.sharedStorage.set(BUILD, value);
            }
        },
        {
            key: "preserveOtherAdditions",
            get: function get() {
                return context.sharedStorage.get(PRESERVE, true);
            },
            set: function set(value) {
                context.sharedStorage.set(PRESERVE, value);
            }
        },
        {
            key: "configured",
            get: function get() {
                return this.bench !== null && this.bin !== null;
            }
        },
        {
            key: "queueTVConfigured",
            get: function get() {
                return this.queuetv !== null;
            }
        },
        {
            key: "asYouGo",
            get: function get() {
                return context.sharedStorage.get(AS_YOU_GO, false);
            },
            set: function set(value) {
                context.sharedStorage.set(AS_YOU_GO, value);
            }
        }
    ]);
    return Settings;
}();
// ui.ts
var LABEL_X = 10;
var INPUT_X = 70;
var y = 0;
function Document() {
    for(var _len = arguments.length, widgets = new Array(_len), _key = 0; _key < _len; _key++){
        widgets[_key] = arguments[_key];
    }
    y = 0;
    return widgets;
}
function Dropdown(text, choices, selectedIndex, onChange) {
    var items = choices.map(function(b) {
        return "".concat(b.name, " ").concat(b.identifier);
    });
    y += 20;
    return [
        {
            type: "label",
            x: LABEL_X,
            y: y,
            width: 60,
            height: 10,
            text: text
        },
        {
            type: "dropdown",
            x: INPUT_X,
            y: y,
            width: 200,
            height: 10,
            items: items,
            selectedIndex: selectedIndex,
            onChange: onChange
        }
    ];
}
function Checkbox(text, isChecked, onChange) {
    y += 15;
    return {
        type: "checkbox",
        x: LABEL_X,
        y: y,
        width: 200,
        height: 15,
        isChecked: isChecked,
        text: text,
        onChange: onChange
    };
}
function Button(text, onClick) {
    y += 20;
    return {
        type: "button",
        text: text,
        x: 10,
        y: y,
        width: 100,
        height: 20,
        onClick: onClick
    };
}
// benchwarmer.ts
var name = "Benchwarmer";
function main() {
    var additions = context.getAllObjects("footpath_addition");
    var settings = new Settings(additions);
    ui.registerMenuItem(name, function() {
        var window = ui.openWindow({
            title: name,
            id: 1,
            classification: name,
            width: 300,
            height: 160,
            widgets: Document.apply(void 0, _to_consumable_array(Dropdown("Bench:", settings.benches, settings.selections.bench, function(index) {
                settings.bench = index;
            })).concat(_to_consumable_array(Dropdown("Bin:", settings.bins, settings.selections.bin, function(index) {
                settings.bin = index;
            })), _to_consumable_array(Dropdown("Queue TV:", settings.queuetvs, settings.selections.queuetv, function(index) {
                settings.queuetv = index;
            })), [
                Checkbox("Build bins on all sloped footpaths", settings.buildBinsOnAllSlopedPaths, function(checked) {
                    settings.buildBinsOnAllSlopedPaths = checked;
                }),
                Checkbox("Preserve other additions (e.g. lamps)", settings.preserveOtherAdditions, function(checked) {
                    settings.preserveOtherAdditions = checked;
                }),
                Checkbox("Add benches and bins as paths are placed", settings.asYouGo, function(checked) {
                    settings.asYouGo = checked;
                }),
                Button("Build on All Paths", function() {
                    if (settings.configured) {
                        try {
                            Add(settings);
                        } catch (e) {
                            ui.showError("Error Building Benches/Bins", e.message);
                        }
                    }
                    window.close();
                })
            ]))
        });
    });
    context.subscribe("action.execute", function(param) {
        var action = param.action, args = param.args, isClientOnly = param.isClientOnly;
        if (action === "footpathplace" && settings.asYouGo && !isClientOnly) {
            var x = args.x, y2 = args.y, z = args.z, slope = args.slope, constructFlags = args.constructFlags;
            var addition = settings.bin;
            if (constructFlags === 1) {
                addition = settings.queuetv;
            } else {
                addition = slope ? settings.bin : findAddition(settings.bench, settings.bin, x / 32, y2 / 32);
            }
            context.executeAction("footpathadditionplace", {
                x: x,
                y: y2,
                z: z,
                object: addition
            }, function(param) {
                var errorTitle = param.errorTitle, errorMessage = param.errorMessage;
                if (errorMessage) throw new Error("".concat(errorTitle, ": ").concat(errorMessage));
            });
        }
    });
}
registerPlugin({
    name: name,
    version: version,
    licence: license,
    authors: [
        author
    ],
    type: "local",
    main: main,
    minApiVersion: 68,
    targetApiVersion: 77
});
