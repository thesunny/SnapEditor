(function () {
/**
 * almond 0.0.3 Copyright (c) 2011, The Dojo Foundation All Rights Reserved.
 * Available via the MIT or new BSD license.
 * see: http://github.com/jrburke/almond for details
 */
/*jslint strict: false, plusplus: false */
/*global setTimeout: false */

var requirejs, require, define;
(function (undef) {

    var defined = {},
        waiting = {},
        aps = [].slice,
        main, req;

    if (typeof define === "function") {
        //If a define is already in play via another AMD loader,
        //do not overwrite.
        return;
    }

    /**
     * Given a relative module name, like ./something, normalize it to
     * a real name that can be mapped to a path.
     * @param {String} name the relative name
     * @param {String} baseName a real name that the name arg is relative
     * to.
     * @returns {String} normalized name
     */
    function normalize(name, baseName) {
        //Adjust any relative paths.
        if (name && name.charAt(0) === ".") {
            //If have a base name, try to normalize against it,
            //otherwise, assume it is a top-level require that will
            //be relative to baseUrl in the end.
            if (baseName) {
                //Convert baseName to array, and lop off the last part,
                //so that . matches that "directory" and not name of the baseName's
                //module. For instance, baseName of "one/two/three", maps to
                //"one/two/three.js", but we want the directory, "one/two" for
                //this normalization.
                baseName = baseName.split("/");
                baseName = baseName.slice(0, baseName.length - 1);

                name = baseName.concat(name.split("/"));

                //start trimDots
                var i, part;
                for (i = 0; (part = name[i]); i++) {
                    if (part === ".") {
                        name.splice(i, 1);
                        i -= 1;
                    } else if (part === "..") {
                        if (i === 1 && (name[2] === '..' || name[0] === '..')) {
                            //End of the line. Keep at least one non-dot
                            //path segment at the front so it can be mapped
                            //correctly to disk. Otherwise, there is likely
                            //no path mapping for a path starting with '..'.
                            //This can still fail, but catches the most reasonable
                            //uses of ..
                            break;
                        } else if (i > 0) {
                            name.splice(i - 1, 2);
                            i -= 2;
                        }
                    }
                }
                //end trimDots

                name = name.join("/");
            }
        }
        return name;
    }

    function makeRequire(relName, forceSync) {
        return function () {
            //A version of a require function that passes a moduleName
            //value for items that may need to
            //look up paths relative to the moduleName
            return req.apply(undef, aps.call(arguments, 0).concat([relName, forceSync]));
        };
    }

    function makeNormalize(relName) {
        return function (name) {
            return normalize(name, relName);
        };
    }

    function makeLoad(depName) {
        return function (value) {
            defined[depName] = value;
        };
    }

    function callDep(name) {
        if (waiting.hasOwnProperty(name)) {
            var args = waiting[name];
            delete waiting[name];
            main.apply(undef, args);
        }
        return defined[name];
    }

    /**
     * Makes a name map, normalizing the name, and using a plugin
     * for normalization if necessary. Grabs a ref to plugin
     * too, as an optimization.
     */
    function makeMap(name, relName) {
        var prefix, plugin,
            index = name.indexOf('!');

        if (index !== -1) {
            prefix = normalize(name.slice(0, index), relName);
            name = name.slice(index + 1);
            plugin = callDep(prefix);

            //Normalize according
            if (plugin && plugin.normalize) {
                name = plugin.normalize(name, makeNormalize(relName));
            } else {
                name = normalize(name, relName);
            }
        } else {
            name = normalize(name, relName);
        }

        //Using ridiculous property names for space reasons
        return {
            f: prefix ? prefix + '!' + name : name, //fullName
            n: name,
            p: plugin
        };
    }

    main = function (name, deps, callback, relName) {
        var args = [],
            usingExports,
            cjsModule, depName, i, ret, map;

        //Use name if no relName
        if (!relName) {
            relName = name;
        }

        //Call the callback to define the module, if necessary.
        if (typeof callback === 'function') {

            //Default to require, exports, module if no deps if
            //the factory arg has any arguments specified.
            if (!deps.length && callback.length) {
                deps = ['require', 'exports', 'module'];
            }

            //Pull out the defined dependencies and pass the ordered
            //values to the callback.
            for (i = 0; i < deps.length; i++) {
                map = makeMap(deps[i], relName);
                depName = map.f;

                //Fast path CommonJS standard dependencies.
                if (depName === "require") {
                    args[i] = makeRequire(name);
                } else if (depName === "exports") {
                    //CommonJS module spec 1.1
                    args[i] = defined[name] = {};
                    usingExports = true;
                } else if (depName === "module") {
                    //CommonJS module spec 1.1
                    cjsModule = args[i] = {
                        id: name,
                        uri: '',
                        exports: defined[name]
                    };
                } else if (defined.hasOwnProperty(depName) || waiting.hasOwnProperty(depName)) {
                    args[i] = callDep(depName);
                } else if (map.p) {
                    map.p.load(map.n, makeRequire(relName, true), makeLoad(depName), {});
                    args[i] = defined[depName];
                } else {
                    throw name + ' missing ' + depName;
                }
            }

            ret = callback.apply(defined[name], args);

            if (name) {
                //If setting exports via "module" is in play,
                //favor that over return value and exports. After that,
                //favor a non-undefined return value over exports use.
                if (cjsModule && cjsModule.exports !== undef) {
                    defined[name] = cjsModule.exports;
                } else if (!usingExports) {
                    //Use the return value from the function.
                    defined[name] = ret;
                }
            }
        } else if (name) {
            //May just be an object definition for the module. Only
            //worry about defining if have a module name.
            defined[name] = callback;
        }
    };

    requirejs = req = function (deps, callback, relName, forceSync) {
        if (typeof deps === "string") {

            //Just return the module wanted. In this scenario, the
            //deps arg is the module name, and second arg (if passed)
            //is just the relName.
            //Normalize module name, if it contains . or ..
            return callDep(makeMap(deps, callback).f);
        } else if (!deps.splice) {
            //deps is a config object, not an array.
            //Drop the config stuff on the ground.
            if (callback.splice) {
                //callback is an array, which means it is a dependency list.
                //Adjust args if there are dependencies
                deps = callback;
                callback = arguments[2];
            } else {
                deps = [];
            }
        }

        //Simulate async callback;
        if (forceSync) {
            main(undef, deps, callback, relName);
        } else {
            setTimeout(function () {
                main(undef, deps, callback, relName);
            }, 15);
        }

        return req;
    };

    /**
     * Just drops the config on the floor, but returns req in case
     * the config return value is used.
     */
    req.config = function () {
        return req;
    };

    /**
     * Export require as a global, but only if it does not already exist.
     */
    if (!require) {
        require = req;
    }

    define = function (name, deps, callback) {

        //This module may not have dependencies
        if (!deps.splice) {
            //deps is not an array, so probably means
            //an object literal or factory function for
            //the value. Adjust args.
            callback = deps;
            deps = [];
        }

        if (define.unordered) {
            waiting[name] = [name, deps, callback];
        } else {
            main(name, deps, callback);
        }
    };

    define.amd = {
        jQuery: true
    };
}());

define("../build/almond.js", function(){});

/*! jQuery v1.7.1 jquery.com | jquery.org/license */
(function(a,b){function cy(a){return f.isWindow(a)?a:a.nodeType===9?a.defaultView||a.parentWindow:!1}function cv(a){if(!ck[a]){var b=c.body,d=f("<"+a+">").appendTo(b),e=d.css("display");d.remove();if(e==="none"||e===""){cl||(cl=c.createElement("iframe"),cl.frameBorder=cl.width=cl.height=0),b.appendChild(cl);if(!cm||!cl.createElement)cm=(cl.contentWindow||cl.contentDocument).document,cm.write((c.compatMode==="CSS1Compat"?"<!doctype html>":"")+"<html><body>"),cm.close();d=cm.createElement(a),cm.body.appendChild(d),e=f.css(d,"display"),b.removeChild(cl)}ck[a]=e}return ck[a]}function cu(a,b){var c={};f.each(cq.concat.apply([],cq.slice(0,b)),function(){c[this]=a});return c}function ct(){cr=b}function cs(){setTimeout(ct,0);return cr=f.now()}function cj(){try{return new a.ActiveXObject("Microsoft.XMLHTTP")}catch(b){}}function ci(){try{return new a.XMLHttpRequest}catch(b){}}function cc(a,c){a.dataFilter&&(c=a.dataFilter(c,a.dataType));var d=a.dataTypes,e={},g,h,i=d.length,j,k=d[0],l,m,n,o,p;for(g=1;g<i;g++){if(g===1)for(h in a.converters)typeof h=="string"&&(e[h.toLowerCase()]=a.converters[h]);l=k,k=d[g];if(k==="*")k=l;else if(l!=="*"&&l!==k){m=l+" "+k,n=e[m]||e["* "+k];if(!n){p=b;for(o in e){j=o.split(" ");if(j[0]===l||j[0]==="*"){p=e[j[1]+" "+k];if(p){o=e[o],o===!0?n=p:p===!0&&(n=o);break}}}}!n&&!p&&f.error("No conversion from "+m.replace(" "," to ")),n!==!0&&(c=n?n(c):p(o(c)))}}return c}function cb(a,c,d){var e=a.contents,f=a.dataTypes,g=a.responseFields,h,i,j,k;for(i in g)i in d&&(c[g[i]]=d[i]);while(f[0]==="*")f.shift(),h===b&&(h=a.mimeType||c.getResponseHeader("content-type"));if(h)for(i in e)if(e[i]&&e[i].test(h)){f.unshift(i);break}if(f[0]in d)j=f[0];else{for(i in d){if(!f[0]||a.converters[i+" "+f[0]]){j=i;break}k||(k=i)}j=j||k}if(j){j!==f[0]&&f.unshift(j);return d[j]}}function ca(a,b,c,d){if(f.isArray(b))f.each(b,function(b,e){c||bE.test(a)?d(a,e):ca(a+"["+(typeof e=="object"||f.isArray(e)?b:"")+"]",e,c,d)});else if(!c&&b!=null&&typeof b=="object")for(var e in b)ca(a+"["+e+"]",b[e],c,d);else d(a,b)}function b_(a,c){var d,e,g=f.ajaxSettings.flatOptions||{};for(d in c)c[d]!==b&&((g[d]?a:e||(e={}))[d]=c[d]);e&&f.extend(!0,a,e)}function b$(a,c,d,e,f,g){f=f||c.dataTypes[0],g=g||{},g[f]=!0;var h=a[f],i=0,j=h?h.length:0,k=a===bT,l;for(;i<j&&(k||!l);i++)l=h[i](c,d,e),typeof l=="string"&&(!k||g[l]?l=b:(c.dataTypes.unshift(l),l=b$(a,c,d,e,l,g)));(k||!l)&&!g["*"]&&(l=b$(a,c,d,e,"*",g));return l}function bZ(a){return function(b,c){typeof b!="string"&&(c=b,b="*");if(f.isFunction(c)){var d=b.toLowerCase().split(bP),e=0,g=d.length,h,i,j;for(;e<g;e++)h=d[e],j=/^\+/.test(h),j&&(h=h.substr(1)||"*"),i=a[h]=a[h]||[],i[j?"unshift":"push"](c)}}}function bC(a,b,c){var d=b==="width"?a.offsetWidth:a.offsetHeight,e=b==="width"?bx:by,g=0,h=e.length;if(d>0){if(c!=="border")for(;g<h;g++)c||(d-=parseFloat(f.css(a,"padding"+e[g]))||0),c==="margin"?d+=parseFloat(f.css(a,c+e[g]))||0:d-=parseFloat(f.css(a,"border"+e[g]+"Width"))||0;return d+"px"}d=bz(a,b,b);if(d<0||d==null)d=a.style[b]||0;d=parseFloat(d)||0;if(c)for(;g<h;g++)d+=parseFloat(f.css(a,"padding"+e[g]))||0,c!=="padding"&&(d+=parseFloat(f.css(a,"border"+e[g]+"Width"))||0),c==="margin"&&(d+=parseFloat(f.css(a,c+e[g]))||0);return d+"px"}function bp(a,b){b.src?f.ajax({url:b.src,async:!1,dataType:"script"}):f.globalEval((b.text||b.textContent||b.innerHTML||"").replace(bf,"/*$0*/")),b.parentNode&&b.parentNode.removeChild(b)}function bo(a){var b=c.createElement("div");bh.appendChild(b),b.innerHTML=a.outerHTML;return b.firstChild}function bn(a){var b=(a.nodeName||"").toLowerCase();b==="input"?bm(a):b!=="script"&&typeof a.getElementsByTagName!="undefined"&&f.grep(a.getElementsByTagName("input"),bm)}function bm(a){if(a.type==="checkbox"||a.type==="radio")a.defaultChecked=a.checked}function bl(a){return typeof a.getElementsByTagName!="undefined"?a.getElementsByTagName("*"):typeof a.querySelectorAll!="undefined"?a.querySelectorAll("*"):[]}function bk(a,b){var c;if(b.nodeType===1){b.clearAttributes&&b.clearAttributes(),b.mergeAttributes&&b.mergeAttributes(a),c=b.nodeName.toLowerCase();if(c==="object")b.outerHTML=a.outerHTML;else if(c!=="input"||a.type!=="checkbox"&&a.type!=="radio"){if(c==="option")b.selected=a.defaultSelected;else if(c==="input"||c==="textarea")b.defaultValue=a.defaultValue}else a.checked&&(b.defaultChecked=b.checked=a.checked),b.value!==a.value&&(b.value=a.value);b.removeAttribute(f.expando)}}function bj(a,b){if(b.nodeType===1&&!!f.hasData(a)){var c,d,e,g=f._data(a),h=f._data(b,g),i=g.events;if(i){delete h.handle,h.events={};for(c in i)for(d=0,e=i[c].length;d<e;d++)f.event.add(b,c+(i[c][d].namespace?".":"")+i[c][d].namespace,i[c][d],i[c][d].data)}h.data&&(h.data=f.extend({},h.data))}}function bi(a,b){return f.nodeName(a,"table")?a.getElementsByTagName("tbody")[0]||a.appendChild(a.ownerDocument.createElement("tbody")):a}function U(a){var b=V.split("|"),c=a.createDocumentFragment();if(c.createElement)while(b.length)c.createElement(b.pop());return c}function T(a,b,c){b=b||0;if(f.isFunction(b))return f.grep(a,function(a,d){var e=!!b.call(a,d,a);return e===c});if(b.nodeType)return f.grep(a,function(a,d){return a===b===c});if(typeof b=="string"){var d=f.grep(a,function(a){return a.nodeType===1});if(O.test(b))return f.filter(b,d,!c);b=f.filter(b,d)}return f.grep(a,function(a,d){return f.inArray(a,b)>=0===c})}function S(a){return!a||!a.parentNode||a.parentNode.nodeType===11}function K(){return!0}function J(){return!1}function n(a,b,c){var d=b+"defer",e=b+"queue",g=b+"mark",h=f._data(a,d);h&&(c==="queue"||!f._data(a,e))&&(c==="mark"||!f._data(a,g))&&setTimeout(function(){!f._data(a,e)&&!f._data(a,g)&&(f.removeData(a,d,!0),h.fire())},0)}function m(a){for(var b in a){if(b==="data"&&f.isEmptyObject(a[b]))continue;if(b!=="toJSON")return!1}return!0}function l(a,c,d){if(d===b&&a.nodeType===1){var e="data-"+c.replace(k,"-$1").toLowerCase();d=a.getAttribute(e);if(typeof d=="string"){try{d=d==="true"?!0:d==="false"?!1:d==="null"?null:f.isNumeric(d)?parseFloat(d):j.test(d)?f.parseJSON(d):d}catch(g){}f.data(a,c,d)}else d=b}return d}function h(a){var b=g[a]={},c,d;a=a.split(/\s+/);for(c=0,d=a.length;c<d;c++)b[a[c]]=!0;return b}var c=a.document,d=a.navigator,e=a.location,f=function(){function J(){if(!e.isReady){try{c.documentElement.doScroll("left")}catch(a){setTimeout(J,1);return}e.ready()}}var e=function(a,b){return new e.fn.init(a,b,h)},f=a.jQuery,g=a.$,h,i=/^(?:[^#<]*(<[\w\W]+>)[^>]*$|#([\w\-]*)$)/,j=/\S/,k=/^\s+/,l=/\s+$/,m=/^<(\w+)\s*\/?>(?:<\/\1>)?$/,n=/^[\],:{}\s]*$/,o=/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,p=/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,q=/(?:^|:|,)(?:\s*\[)+/g,r=/(webkit)[ \/]([\w.]+)/,s=/(opera)(?:.*version)?[ \/]([\w.]+)/,t=/(msie) ([\w.]+)/,u=/(mozilla)(?:.*? rv:([\w.]+))?/,v=/-([a-z]|[0-9])/ig,w=/^-ms-/,x=function(a,b){return(b+"").toUpperCase()},y=d.userAgent,z,A,B,C=Object.prototype.toString,D=Object.prototype.hasOwnProperty,E=Array.prototype.push,F=Array.prototype.slice,G=String.prototype.trim,H=Array.prototype.indexOf,I={};e.fn=e.prototype={constructor:e,init:function(a,d,f){var g,h,j,k;if(!a)return this;if(a.nodeType){this.context=this[0]=a,this.length=1;return this}if(a==="body"&&!d&&c.body){this.context=c,this[0]=c.body,this.selector=a,this.length=1;return this}if(typeof a=="string"){a.charAt(0)!=="<"||a.charAt(a.length-1)!==">"||a.length<3?g=i.exec(a):g=[null,a,null];if(g&&(g[1]||!d)){if(g[1]){d=d instanceof e?d[0]:d,k=d?d.ownerDocument||d:c,j=m.exec(a),j?e.isPlainObject(d)?(a=[c.createElement(j[1])],e.fn.attr.call(a,d,!0)):a=[k.createElement(j[1])]:(j=e.buildFragment([g[1]],[k]),a=(j.cacheable?e.clone(j.fragment):j.fragment).childNodes);return e.merge(this,a)}h=c.getElementById(g[2]);if(h&&h.parentNode){if(h.id!==g[2])return f.find(a);this.length=1,this[0]=h}this.context=c,this.selector=a;return this}return!d||d.jquery?(d||f).find(a):this.constructor(d).find(a)}if(e.isFunction(a))return f.ready(a);a.selector!==b&&(this.selector=a.selector,this.context=a.context);return e.makeArray(a,this)},selector:"",jquery:"1.7.1",length:0,size:function(){return this.length},toArray:function(){return F.call(this,0)},get:function(a){return a==null?this.toArray():a<0?this[this.length+a]:this[a]},pushStack:function(a,b,c){var d=this.constructor();e.isArray(a)?E.apply(d,a):e.merge(d,a),d.prevObject=this,d.context=this.context,b==="find"?d.selector=this.selector+(this.selector?" ":"")+c:b&&(d.selector=this.selector+"."+b+"("+c+")");return d},each:function(a,b){return e.each(this,a,b)},ready:function(a){e.bindReady(),A.add(a);return this},eq:function(a){a=+a;return a===-1?this.slice(a):this.slice(a,a+1)},first:function(){return this.eq(0)},last:function(){return this.eq(-1)},slice:function(){return this.pushStack(F.apply(this,arguments),"slice",F.call(arguments).join(","))},map:function(a){return this.pushStack(e.map(this,function(b,c){return a.call(b,c,b)}))},end:function(){return this.prevObject||this.constructor(null)},push:E,sort:[].sort,splice:[].splice},e.fn.init.prototype=e.fn,e.extend=e.fn.extend=function(){var a,c,d,f,g,h,i=arguments[0]||{},j=1,k=arguments.length,l=!1;typeof i=="boolean"&&(l=i,i=arguments[1]||{},j=2),typeof i!="object"&&!e.isFunction(i)&&(i={}),k===j&&(i=this,--j);for(;j<k;j++)if((a=arguments[j])!=null)for(c in a){d=i[c],f=a[c];if(i===f)continue;l&&f&&(e.isPlainObject(f)||(g=e.isArray(f)))?(g?(g=!1,h=d&&e.isArray(d)?d:[]):h=d&&e.isPlainObject(d)?d:{},i[c]=e.extend(l,h,f)):f!==b&&(i[c]=f)}return i},e.extend({noConflict:function(b){a.$===e&&(a.$=g),b&&a.jQuery===e&&(a.jQuery=f);return e},isReady:!1,readyWait:1,holdReady:function(a){a?e.readyWait++:e.ready(!0)},ready:function(a){if(a===!0&&!--e.readyWait||a!==!0&&!e.isReady){if(!c.body)return setTimeout(e.ready,1);e.isReady=!0;if(a!==!0&&--e.readyWait>0)return;A.fireWith(c,[e]),e.fn.trigger&&e(c).trigger("ready").off("ready")}},bindReady:function(){if(!A){A=e.Callbacks("once memory");if(c.readyState==="complete")return setTimeout(e.ready,1);if(c.addEventListener)c.addEventListener("DOMContentLoaded",B,!1),a.addEventListener("load",e.ready,!1);else if(c.attachEvent){c.attachEvent("onreadystatechange",B),a.attachEvent("onload",e.ready);var b=!1;try{b=a.frameElement==null}catch(d){}c.documentElement.doScroll&&b&&J()}}},isFunction:function(a){return e.type(a)==="function"},isArray:Array.isArray||function(a){return e.type(a)==="array"},isWindow:function(a){return a&&typeof a=="object"&&"setInterval"in a},isNumeric:function(a){return!isNaN(parseFloat(a))&&isFinite(a)},type:function(a){return a==null?String(a):I[C.call(a)]||"object"},isPlainObject:function(a){if(!a||e.type(a)!=="object"||a.nodeType||e.isWindow(a))return!1;try{if(a.constructor&&!D.call(a,"constructor")&&!D.call(a.constructor.prototype,"isPrototypeOf"))return!1}catch(c){return!1}var d;for(d in a);return d===b||D.call(a,d)},isEmptyObject:function(a){for(var b in a)return!1;return!0},error:function(a){throw new Error(a)},parseJSON:function(b){if(typeof b!="string"||!b)return null;b=e.trim(b);if(a.JSON&&a.JSON.parse)return a.JSON.parse(b);if(n.test(b.replace(o,"@").replace(p,"]").replace(q,"")))return(new Function("return "+b))();e.error("Invalid JSON: "+b)},parseXML:function(c){var d,f;try{a.DOMParser?(f=new DOMParser,d=f.parseFromString(c,"text/xml")):(d=new ActiveXObject("Microsoft.XMLDOM"),d.async="false",d.loadXML(c))}catch(g){d=b}(!d||!d.documentElement||d.getElementsByTagName("parsererror").length)&&e.error("Invalid XML: "+c);return d},noop:function(){},globalEval:function(b){b&&j.test(b)&&(a.execScript||function(b){a.eval.call(a,b)})(b)},camelCase:function(a){return a.replace(w,"ms-").replace(v,x)},nodeName:function(a,b){return a.nodeName&&a.nodeName.toUpperCase()===b.toUpperCase()},each:function(a,c,d){var f,g=0,h=a.length,i=h===b||e.isFunction(a);if(d){if(i){for(f in a)if(c.apply(a[f],d)===!1)break}else for(;g<h;)if(c.apply(a[g++],d)===!1)break}else if(i){for(f in a)if(c.call(a[f],f,a[f])===!1)break}else for(;g<h;)if(c.call(a[g],g,a[g++])===!1)break;return a},trim:G?function(a){return a==null?"":G.call(a)}:function(a){return a==null?"":(a+"").replace(k,"").replace(l,"")},makeArray:function(a,b){var c=b||[];if(a!=null){var d=e.type(a);a.length==null||d==="string"||d==="function"||d==="regexp"||e.isWindow(a)?E.call(c,a):e.merge(c,a)}return c},inArray:function(a,b,c){var d;if(b){if(H)return H.call(b,a,c);d=b.length,c=c?c<0?Math.max(0,d+c):c:0;for(;c<d;c++)if(c in b&&b[c]===a)return c}return-1},merge:function(a,c){var d=a.length,e=0;if(typeof c.length=="number")for(var f=c.length;e<f;e++)a[d++]=c[e];else while(c[e]!==b)a[d++]=c[e++];a.length=d;return a},grep:function(a,b,c){var d=[],e;c=!!c;for(var f=0,g=a.length;f<g;f++)e=!!b(a[f],f),c!==e&&d.push(a[f]);return d},map:function(a,c,d){var f,g,h=[],i=0,j=a.length,k=a instanceof e||j!==b&&typeof j=="number"&&(j>0&&a[0]&&a[j-1]||j===0||e.isArray(a));if(k)for(;i<j;i++)f=c(a[i],i,d),f!=null&&(h[h.length]=f);else for(g in a)f=c(a[g],g,d),f!=null&&(h[h.length]=f);return h.concat.apply([],h)},guid:1,proxy:function(a,c){if(typeof c=="string"){var d=a[c];c=a,a=d}if(!e.isFunction(a))return b;var f=F.call(arguments,2),g=function(){return a.apply(c,f.concat(F.call(arguments)))};g.guid=a.guid=a.guid||g.guid||e.guid++;return g},access:function(a,c,d,f,g,h){var i=a.length;if(typeof c=="object"){for(var j in c)e.access(a,j,c[j],f,g,d);return a}if(d!==b){f=!h&&f&&e.isFunction(d);for(var k=0;k<i;k++)g(a[k],c,f?d.call(a[k],k,g(a[k],c)):d,h);return a}return i?g(a[0],c):b},now:function(){return(new Date).getTime()},uaMatch:function(a){a=a.toLowerCase();var b=r.exec(a)||s.exec(a)||t.exec(a)||a.indexOf("compatible")<0&&u.exec(a)||[];return{browser:b[1]||"",version:b[2]||"0"}},sub:function(){function a(b,c){return new a.fn.init(b,c)}e.extend(!0,a,this),a.superclass=this,a.fn=a.prototype=this(),a.fn.constructor=a,a.sub=this.sub,a.fn.init=function(d,f){f&&f instanceof e&&!(f instanceof a)&&(f=a(f));return e.fn.init.call(this,d,f,b)},a.fn.init.prototype=a.fn;var b=a(c);return a},browser:{}}),e.each("Boolean Number String Function Array Date RegExp Object".split(" "),function(a,b){I["[object "+b+"]"]=b.toLowerCase()}),z=e.uaMatch(y),z.browser&&(e.browser[z.browser]=!0,e.browser.version=z.version),e.browser.webkit&&(e.browser.safari=!0),j.test(" ")&&(k=/^[\s\xA0]+/,l=/[\s\xA0]+$/),h=e(c),c.addEventListener?B=function(){c.removeEventListener("DOMContentLoaded",B,!1),e.ready()}:c.attachEvent&&(B=function(){c.readyState==="complete"&&(c.detachEvent("onreadystatechange",B),e.ready())});return e}(),g={};f.Callbacks=function(a){a=a?g[a]||h(a):{};var c=[],d=[],e,i,j,k,l,m=function(b){var d,e,g,h,i;for(d=0,e=b.length;d<e;d++)g=b[d],h=f.type(g),h==="array"?m(g):h==="function"&&(!a.unique||!o.has(g))&&c.push(g)},n=function(b,f){f=f||[],e=!a.memory||[b,f],i=!0,l=j||0,j=0,k=c.length;for(;c&&l<k;l++)if(c[l].apply(b,f)===!1&&a.stopOnFalse){e=!0;break}i=!1,c&&(a.once?e===!0?o.disable():c=[]:d&&d.length&&(e=d.shift(),o.fireWith(e[0],e[1])))},o={add:function(){if(c){var a=c.length;m(arguments),i?k=c.length:e&&e!==!0&&(j=a,n(e[0],e[1]))}return this},remove:function(){if(c){var b=arguments,d=0,e=b.length;for(;d<e;d++)for(var f=0;f<c.length;f++)if(b[d]===c[f]){i&&f<=k&&(k--,f<=l&&l--),c.splice(f--,1);if(a.unique)break}}return this},has:function(a){if(c){var b=0,d=c.length;for(;b<d;b++)if(a===c[b])return!0}return!1},empty:function(){c=[];return this},disable:function(){c=d=e=b;return this},disabled:function(){return!c},lock:function(){d=b,(!e||e===!0)&&o.disable();return this},locked:function(){return!d},fireWith:function(b,c){d&&(i?a.once||d.push([b,c]):(!a.once||!e)&&n(b,c));return this},fire:function(){o.fireWith(this,arguments);return this},fired:function(){return!!e}};return o};var i=[].slice;f.extend({Deferred:function(a){var b=f.Callbacks("once memory"),c=f.Callbacks("once memory"),d=f.Callbacks("memory"),e="pending",g={resolve:b,reject:c,notify:d},h={done:b.add,fail:c.add,progress:d.add,state:function(){return e},isResolved:b.fired,isRejected:c.fired,then:function(a,b,c){i.done(a).fail(b).progress(c);return this},always:function(){i.done.apply(i,arguments).fail.apply(i,arguments);return this},pipe:function(a,b,c){return f.Deferred(function(d){f.each({done:[a,"resolve"],fail:[b,"reject"],progress:[c,"notify"]},function(a,b){var c=b[0],e=b[1],g;f.isFunction(c)?i[a](function(){g=c.apply(this,arguments),g&&f.isFunction(g.promise)?g.promise().then(d.resolve,d.reject,d.notify):d[e+"With"](this===i?d:this,[g])}):i[a](d[e])})}).promise()},promise:function(a){if(a==null)a=h;else for(var b in h)a[b]=h[b];return a}},i=h.promise({}),j;for(j in g)i[j]=g[j].fire,i[j+"With"]=g[j].fireWith;i.done(function(){e="resolved"},c.disable,d.lock).fail(function(){e="rejected"},b.disable,d.lock),a&&a.call(i,i);return i},when:function(a){function m(a){return function(b){e[a]=arguments.length>1?i.call(arguments,0):b,j.notifyWith(k,e)}}function l(a){return function(c){b[a]=arguments.length>1?i.call(arguments,0):c,--g||j.resolveWith(j,b)}}var b=i.call(arguments,0),c=0,d=b.length,e=Array(d),g=d,h=d,j=d<=1&&a&&f.isFunction(a.promise)?a:f.Deferred(),k=j.promise();if(d>1){for(;c<d;c++)b[c]&&b[c].promise&&f.isFunction(b[c].promise)?b[c].promise().then(l(c),j.reject,m(c)):--g;g||j.resolveWith(j,b)}else j!==a&&j.resolveWith(j,d?[a]:[]);return k}}),f.support=function(){var b,d,e,g,h,i,j,k,l,m,n,o,p,q=c.createElement("div"),r=c.documentElement;q.setAttribute("className","t"),q.innerHTML="   <link/><table></table><a href='/a' style='top:1px;float:left;opacity:.55;'>a</a><input type='checkbox'/>",d=q.getElementsByTagName("*"),e=q.getElementsByTagName("a")[0];if(!d||!d.length||!e)return{};g=c.createElement("select"),h=g.appendChild(c.createElement("option")),i=q.getElementsByTagName("input")[0],b={leadingWhitespace:q.firstChild.nodeType===3,tbody:!q.getElementsByTagName("tbody").length,htmlSerialize:!!q.getElementsByTagName("link").length,style:/top/.test(e.getAttribute("style")),hrefNormalized:e.getAttribute("href")==="/a",opacity:/^0.55/.test(e.style.opacity),cssFloat:!!e.style.cssFloat,checkOn:i.value==="on",optSelected:h.selected,getSetAttribute:q.className!=="t",enctype:!!c.createElement("form").enctype,html5Clone:c.createElement("nav").cloneNode(!0).outerHTML!=="<:nav></:nav>",submitBubbles:!0,changeBubbles:!0,focusinBubbles:!1,deleteExpando:!0,noCloneEvent:!0,inlineBlockNeedsLayout:!1,shrinkWrapBlocks:!1,reliableMarginRight:!0},i.checked=!0,b.noCloneChecked=i.cloneNode(!0).checked,g.disabled=!0,b.optDisabled=!h.disabled;try{delete q.test}catch(s){b.deleteExpando=!1}!q.addEventListener&&q.attachEvent&&q.fireEvent&&(q.attachEvent("onclick",function(){b.noCloneEvent=!1}),q.cloneNode(!0).fireEvent("onclick")),i=c.createElement("input"),i.value="t",i.setAttribute("type","radio"),b.radioValue=i.value==="t",i.setAttribute("checked","checked"),q.appendChild(i),k=c.createDocumentFragment(),k.appendChild(q.lastChild),b.checkClone=k.cloneNode(!0).cloneNode(!0).lastChild.checked,b.appendChecked=i.checked,k.removeChild(i),k.appendChild(q),q.innerHTML="",a.getComputedStyle&&(j=c.createElement("div"),j.style.width="0",j.style.marginRight="0",q.style.width="2px",q.appendChild(j),b.reliableMarginRight=(parseInt((a.getComputedStyle(j,null)||{marginRight:0}).marginRight,10)||0)===0);if(q.attachEvent)for(o in{submit:1,change:1,focusin:1})n="on"+o,p=n in q,p||(q.setAttribute(n,"return;"),p=typeof q[n]=="function"),b[o+"Bubbles"]=p;k.removeChild(q),k=g=h=j=q=i=null,f(function(){var a,d,e,g,h,i,j,k,m,n,o,r=c.getElementsByTagName("body")[0];!r||(j=1,k="position:absolute;top:0;left:0;width:1px;height:1px;margin:0;",m="visibility:hidden;border:0;",n="style='"+k+"border:5px solid #000;padding:0;'",o="<div "+n+"><div></div></div>"+"<table "+n+" cellpadding='0' cellspacing='0'>"+"<tr><td></td></tr></table>",a=c.createElement("div"),a.style.cssText=m+"width:0;height:0;position:static;top:0;margin-top:"+j+"px",r.insertBefore(a,r.firstChild),q=c.createElement("div"),a.appendChild(q),q.innerHTML="<table><tr><td style='padding:0;border:0;display:none'></td><td>t</td></tr></table>",l=q.getElementsByTagName("td"),p=l[0].offsetHeight===0,l[0].style.display="",l[1].style.display="none",b.reliableHiddenOffsets=p&&l[0].offsetHeight===0,q.innerHTML="",q.style.width=q.style.paddingLeft="1px",f.boxModel=b.boxModel=q.offsetWidth===2,typeof q.style.zoom!="undefined"&&(q.style.display="inline",q.style.zoom=1,b.inlineBlockNeedsLayout=q.offsetWidth===2,q.style.display="",q.innerHTML="<div style='width:4px;'></div>",b.shrinkWrapBlocks=q.offsetWidth!==2),q.style.cssText=k+m,q.innerHTML=o,d=q.firstChild,e=d.firstChild,h=d.nextSibling.firstChild.firstChild,i={doesNotAddBorder:e.offsetTop!==5,doesAddBorderForTableAndCells:h.offsetTop===5},e.style.position="fixed",e.style.top="20px",i.fixedPosition=e.offsetTop===20||e.offsetTop===15,e.style.position=e.style.top="",d.style.overflow="hidden",d.style.position="relative",i.subtractsBorderForOverflowNotVisible=e.offsetTop===-5,i.doesNotIncludeMarginInBodyOffset=r.offsetTop!==j,r.removeChild(a),q=a=null,f.extend(b,i))});return b}();var j=/^(?:\{.*\}|\[.*\])$/,k=/([A-Z])/g;f.extend({cache:{},uuid:0,expando:"jQuery"+(f.fn.jquery+Math.random()).replace(/\D/g,""),noData:{embed:!0,object:"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000",applet:!0},hasData:function(a){a=a.nodeType?f.cache[a[f.expando]]:a[f.expando];return!!a&&!m(a)},data:function(a,c,d,e){if(!!f.acceptData(a)){var g,h,i,j=f.expando,k=typeof c=="string",l=a.nodeType,m=l?f.cache:a,n=l?a[j]:a[j]&&j,o=c==="events";if((!n||!m[n]||!o&&!e&&!m[n].data)&&k&&d===b)return;n||(l?a[j]=n=++f.uuid:n=j),m[n]||(m[n]={},l||(m[n].toJSON=f.noop));if(typeof c=="object"||typeof c=="function")e?m[n]=f.extend(m[n],c):m[n].data=f.extend(m[n].data,c);g=h=m[n],e||(h.data||(h.data={}),h=h.data),d!==b&&(h[f.camelCase(c)]=d);if(o&&!h[c])return g.events;k?(i=h[c],i==null&&(i=h[f.camelCase(c)])):i=h;return i}},removeData:function(a,b,c){if(!!f.acceptData(a)){var d,e,g,h=f.expando,i=a.nodeType,j=i?f.cache:a,k=i?a[h]:h;if(!j[k])return;if(b){d=c?j[k]:j[k].data;if(d){f.isArray(b)||(b in d?b=[b]:(b=f.camelCase(b),b in d?b=[b]:b=b.split(" ")));for(e=0,g=b.length;e<g;e++)delete d[b[e]];if(!(c?m:f.isEmptyObject)(d))return}}if(!c){delete j[k].data;if(!m(j[k]))return}f.support.deleteExpando||!j.setInterval?delete j[k]:j[k]=null,i&&(f.support.deleteExpando?delete a[h]:a.removeAttribute?a.removeAttribute(h):a[h]=null)}},_data:function(a,b,c){return f.data(a,b,c,!0)},acceptData:function(a){if(a.nodeName){var b=f.noData[a.nodeName.toLowerCase()];if(b)return b!==!0&&a.getAttribute("classid")===b}return!0}}),f.fn.extend({data:function(a,c){var d,e,g,h=null;if(typeof a=="undefined"){if(this.length){h=f.data(this[0]);if(this[0].nodeType===1&&!f._data(this[0],"parsedAttrs")){e=this[0].attributes;for(var i=0,j=e.length;i<j;i++)g=e[i].name,g.indexOf("data-")===0&&(g=f.camelCase(g.substring(5)),l(this[0],g,h[g]));f._data(this[0],"parsedAttrs",!0)}}return h}if(typeof a=="object")return this.each(function(){f.data(this,a)});d=a.split("."),d[1]=d[1]?"."+d[1]:"";if(c===b){h=this.triggerHandler("getData"+d[1]+"!",[d[0]]),h===b&&this.length&&(h=f.data(this[0],a),h=l(this[0],a,h));return h===b&&d[1]?this.data(d[0]):h}return this.each(function(){var b=f(this),e=[d[0],c];b.triggerHandler("setData"+d[1]+"!",e),f.data(this,a,c),b.triggerHandler("changeData"+d[1]+"!",e)})},removeData:function(a){return this.each(function(){f.removeData(this,a)})}}),f.extend({_mark:function(a,b){a&&(b=(b||"fx")+"mark",f._data(a,b,(f._data(a,b)||0)+1))},_unmark:function(a,b,c){a!==!0&&(c=b,b=a,a=!1);if(b){c=c||"fx";var d=c+"mark",e=a?0:(f._data(b,d)||1)-1;e?f._data(b,d,e):(f.removeData(b,d,!0),n(b,c,"mark"))}},queue:function(a,b,c){var d;if(a){b=(b||"fx")+"queue",d=f._data(a,b),c&&(!d||f.isArray(c)?d=f._data(a,b,f.makeArray(c)):d.push(c));return d||[]}},dequeue:function(a,b){b=b||"fx";var c=f.queue(a,b),d=c.shift(),e={};d==="inprogress"&&(d=c.shift()),d&&(b==="fx"&&c.unshift("inprogress"),f._data(a,b+".run",e),d.call(a,function(){f.dequeue(a,b)},e)),c.length||(f.removeData(a,b+"queue "+b+".run",!0),n(a,b,"queue"))}}),f.fn.extend({queue:function(a,c){typeof a!="string"&&(c=a,a="fx");if(c===b)return f.queue(this[0],a);return this.each(function(){var b=f.queue(this,a,c);a==="fx"&&b[0]!=="inprogress"&&f.dequeue(this,a)})},dequeue:function(a){return this.each(function(){f.dequeue(this,a)})},delay:function(a,b){a=f.fx?f.fx.speeds[a]||a:a,b=b||"fx";return this.queue(b,function(b,c){var d=setTimeout(b,a);c.stop=function(){clearTimeout(d)}})},clearQueue:function(a){return this.queue(a||"fx",[])},promise:function(a,c){function m(){--h||d.resolveWith(e,[e])}typeof a!="string"&&(c=a,a=b),a=a||"fx";var d=f.Deferred(),e=this,g=e.length,h=1,i=a+"defer",j=a+"queue",k=a+"mark",l;while(g--)if(l=f.data(e[g],i,b,!0)||(f.data(e[g],j,b,!0)||f.data(e[g],k,b,!0))&&f.data(e[g],i,f.Callbacks("once memory"),!0))h++,l.add(m);m();return d.promise()}});var o=/[\n\t\r]/g,p=/\s+/,q=/\r/g,r=/^(?:button|input)$/i,s=/^(?:button|input|object|select|textarea)$/i,t=/^a(?:rea)?$/i,u=/^(?:autofocus|autoplay|async|checked|controls|defer|disabled|hidden|loop|multiple|open|readonly|required|scoped|selected)$/i,v=f.support.getSetAttribute,w,x,y;f.fn.extend({attr:function(a,b){return f.access(this,a,b,!0,f.attr)},removeAttr:function(a){return this.each(function(){f.removeAttr(this,a)})},prop:function(a,b){return f.access(this,a,b,!0,f.prop)},removeProp:function(a){a=f.propFix[a]||a;return this.each(function(){try{this[a]=b,delete this[a]}catch(c){}})},addClass:function(a){var b,c,d,e,g,h,i;if(f.isFunction(a))return this.each(function(b){f(this).addClass(a.call(this,b,this.className))});if(a&&typeof a=="string"){b=a.split(p);for(c=0,d=this.length;c<d;c++){e=this[c];if(e.nodeType===1)if(!e.className&&b.length===1)e.className=a;else{g=" "+e.className+" ";for(h=0,i=b.length;h<i;h++)~g.indexOf(" "+b[h]+" ")||(g+=b[h]+" ");e.className=f.trim(g)}}}return this},removeClass:function(a){var c,d,e,g,h,i,j;if(f.isFunction(a))return this.each(function(b){f(this).removeClass(a.call(this,b,this.className))});if(a&&typeof a=="string"||a===b){c=(a||"").split(p);for(d=0,e=this.length;d<e;d++){g=this[d];if(g.nodeType===1&&g.className)if(a){h=(" "+g.className+" ").replace(o," ");for(i=0,j=c.length;i<j;i++)h=h.replace(" "+c[i]+" "," ");g.className=f.trim(h)}else g.className=""}}return this},toggleClass:function(a,b){var c=typeof a,d=typeof b=="boolean";if(f.isFunction(a))return this.each(function(c){f(this).toggleClass(a.call(this,c,this.className,b),b)});return this.each(function(){if(c==="string"){var e,g=0,h=f(this),i=b,j=a.split(p);while(e=j[g++])i=d?i:!h.hasClass(e),h[i?"addClass":"removeClass"](e)}else if(c==="undefined"||c==="boolean")this.className&&f._data(this,"__className__",this.className),this.className=this.className||a===!1?"":f._data(this,"__className__")||""})},hasClass:function(a){var b=" "+a+" ",c=0,d=this.length;for(;c<d;c++)if(this[c].nodeType===1&&(" "+this[c].className+" ").replace(o," ").indexOf(b)>-1)return!0;return!1},val:function(a){var c,d,e,g=this[0];{if(!!arguments.length){e=f.isFunction(a);return this.each(function(d){var g=f(this),h;if(this.nodeType===1){e?h=a.call(this,d,g.val()):h=a,h==null?h="":typeof h=="number"?h+="":f.isArray(h)&&(h=f.map(h,function(a){return a==null?"":a+""})),c=f.valHooks[this.nodeName.toLowerCase()]||f.valHooks[this.type];if(!c||!("set"in c)||c.set(this,h,"value")===b)this.value=h}})}if(g){c=f.valHooks[g.nodeName.toLowerCase()]||f.valHooks[g.type];if(c&&"get"in c&&(d=c.get(g,"value"))!==b)return d;d=g.value;return typeof d=="string"?d.replace(q,""):d==null?"":d}}}}),f.extend({valHooks:{option:{get:function(a){var b=a.attributes.value;return!b||b.specified?a.value:a.text}},select:{get:function(a){var b,c,d,e,g=a.selectedIndex,h=[],i=a.options,j=a.type==="select-one";if(g<0)return null;c=j?g:0,d=j?g+1:i.length;for(;c<d;c++){e=i[c];if(e.selected&&(f.support.optDisabled?!e.disabled:e.getAttribute("disabled")===null)&&(!e.parentNode.disabled||!f.nodeName(e.parentNode,"optgroup"))){b=f(e).val();if(j)return b;h.push(b)}}if(j&&!h.length&&i.length)return f(i[g]).val();return h},set:function(a,b){var c=f.makeArray(b);f(a).find("option").each(function(){this.selected=f.inArray(f(this).val(),c)>=0}),c.length||(a.selectedIndex=-1);return c}}},attrFn:{val:!0,css:!0,html:!0,text:!0,data:!0,width:!0,height:!0,offset:!0},attr:function(a,c,d,e){var g,h,i,j=a.nodeType;if(!!a&&j!==3&&j!==8&&j!==2){if(e&&c in f.attrFn)return f(a)[c](d);if(typeof a.getAttribute=="undefined")return f.prop(a,c,d);i=j!==1||!f.isXMLDoc(a),i&&(c=c.toLowerCase(),h=f.attrHooks[c]||(u.test(c)?x:w));if(d!==b){if(d===null){f.removeAttr(a,c);return}if(h&&"set"in h&&i&&(g=h.set(a,d,c))!==b)return g;a.setAttribute(c,""+d);return d}if(h&&"get"in h&&i&&(g=h.get(a,c))!==null)return g;g=a.getAttribute(c);return g===null?b:g}},removeAttr:function(a,b){var c,d,e,g,h=0;if(b&&a.nodeType===1){d=b.toLowerCase().split(p),g=d.length;for(;h<g;h++)e=d[h],e&&(c=f.propFix[e]||e,f.attr(a,e,""),a.removeAttribute(v?e:c),u.test(e)&&c in a&&(a[c]=!1))}},attrHooks:{type:{set:function(a,b){if(r.test(a.nodeName)&&a.parentNode)f.error("type property can't be changed");else if(!f.support.radioValue&&b==="radio"&&f.nodeName(a,"input")){var c=a.value;a.setAttribute("type",b),c&&(a.value=c);return b}}},value:{get:function(a,b){if(w&&f.nodeName(a,"button"))return w.get(a,b);return b in a?a.value:null},set:function(a,b,c){if(w&&f.nodeName(a,"button"))return w.set(a,b,c);a.value=b}}},propFix:{tabindex:"tabIndex",readonly:"readOnly","for":"htmlFor","class":"className",maxlength:"maxLength",cellspacing:"cellSpacing",cellpadding:"cellPadding",rowspan:"rowSpan",colspan:"colSpan",usemap:"useMap",frameborder:"frameBorder",contenteditable:"contentEditable"},prop:function(a,c,d){var e,g,h,i=a.nodeType;if(!!a&&i!==3&&i!==8&&i!==2){h=i!==1||!f.isXMLDoc(a),h&&(c=f.propFix[c]||c,g=f.propHooks[c]);return d!==b?g&&"set"in g&&(e=g.set(a,d,c))!==b?e:a[c]=d:g&&"get"in g&&(e=g.get(a,c))!==null?e:a[c]}},propHooks:{tabIndex:{get:function(a){var c=a.getAttributeNode("tabindex");return c&&c.specified?parseInt(c.value,10):s.test(a.nodeName)||t.test(a.nodeName)&&a.href?0:b}}}}),f.attrHooks.tabindex=f.propHooks.tabIndex,x={get:function(a,c){var d,e=f.prop(a,c);return e===!0||typeof e!="boolean"&&(d=a.getAttributeNode(c))&&d.nodeValue!==!1?c.toLowerCase():b},set:function(a,b,c){var d;b===!1?f.removeAttr(a,c):(d=f.propFix[c]||c,d in a&&(a[d]=!0),a.setAttribute(c,c.toLowerCase()));return c}},v||(y={name:!0,id:!0},w=f.valHooks.button={get:function(a,c){var d;d=a.getAttributeNode(c);return d&&(y[c]?d.nodeValue!=="":d.specified)?d.nodeValue:b},set:function(a,b,d){var e=a.getAttributeNode(d);e||(e=c.createAttribute(d),a.setAttributeNode(e));return e.nodeValue=b+""}},f.attrHooks.tabindex.set=w.set,f.each(["width","height"],function(a,b){f.attrHooks[b]=f.extend(f.attrHooks[b],{set:function(a,c){if(c===""){a.setAttribute(b,"auto");return c}}})}),f.attrHooks.contenteditable={get:w.get,set:function(a,b,c){b===""&&(b="false"),w.set(a,b,c)}}),f.support.hrefNormalized||f.each(["href","src","width","height"],function(a,c){f.attrHooks[c]=f.extend(f.attrHooks[c],{get:function(a){var d=a.getAttribute(c,2);return d===null?b:d}})}),f.support.style||(f.attrHooks.style={get:function(a){return a.style.cssText.toLowerCase()||b},set:function(a,b){return a.style.cssText=""+b}}),f.support.optSelected||(f.propHooks.selected=f.extend(f.propHooks.selected,{get:function(a){var b=a.parentNode;b&&(b.selectedIndex,b.parentNode&&b.parentNode.selectedIndex);return null}})),f.support.enctype||(f.propFix.enctype="encoding"),f.support.checkOn||f.each(["radio","checkbox"],function(){f.valHooks[this]={get:function(a){return a.getAttribute("value")===null?"on":a.value}}}),f.each(["radio","checkbox"],function(){f.valHooks[this]=f.extend(f.valHooks[this],{set:function(a,b){if(f.isArray(b))return a.checked=f.inArray(f(a).val(),b)>=0}})});var z=/^(?:textarea|input|select)$/i,A=/^([^\.]*)?(?:\.(.+))?$/,B=/\bhover(\.\S+)?\b/,C=/^key/,D=/^(?:mouse|contextmenu)|click/,E=/^(?:focusinfocus|focusoutblur)$/,F=/^(\w*)(?:#([\w\-]+))?(?:\.([\w\-]+))?$/,G=function(a){var b=F.exec(a);b&&(b[1]=(b[1]||"").toLowerCase(),b[3]=b[3]&&new RegExp("(?:^|\\s)"+b[3]+"(?:\\s|$)"));return b},H=function(a,b){var c=a.attributes||{};return(!b[1]||a.nodeName.toLowerCase()===b[1])&&(!b[2]||(c.id||{}).value===b[2])&&(!b[3]||b[3].test((c["class"]||{}).value))},I=function(a){return f.event.special.hover?a:a.replace(B,"mouseenter$1 mouseleave$1")};
f.event={add:function(a,c,d,e,g){var h,i,j,k,l,m,n,o,p,q,r,s;if(!(a.nodeType===3||a.nodeType===8||!c||!d||!(h=f._data(a)))){d.handler&&(p=d,d=p.handler),d.guid||(d.guid=f.guid++),j=h.events,j||(h.events=j={}),i=h.handle,i||(h.handle=i=function(a){return typeof f!="undefined"&&(!a||f.event.triggered!==a.type)?f.event.dispatch.apply(i.elem,arguments):b},i.elem=a),c=f.trim(I(c)).split(" ");for(k=0;k<c.length;k++){l=A.exec(c[k])||[],m=l[1],n=(l[2]||"").split(".").sort(),s=f.event.special[m]||{},m=(g?s.delegateType:s.bindType)||m,s=f.event.special[m]||{},o=f.extend({type:m,origType:l[1],data:e,handler:d,guid:d.guid,selector:g,quick:G(g),namespace:n.join(".")},p),r=j[m];if(!r){r=j[m]=[],r.delegateCount=0;if(!s.setup||s.setup.call(a,e,n,i)===!1)a.addEventListener?a.addEventListener(m,i,!1):a.attachEvent&&a.attachEvent("on"+m,i)}s.add&&(s.add.call(a,o),o.handler.guid||(o.handler.guid=d.guid)),g?r.splice(r.delegateCount++,0,o):r.push(o),f.event.global[m]=!0}a=null}},global:{},remove:function(a,b,c,d,e){var g=f.hasData(a)&&f._data(a),h,i,j,k,l,m,n,o,p,q,r,s;if(!!g&&!!(o=g.events)){b=f.trim(I(b||"")).split(" ");for(h=0;h<b.length;h++){i=A.exec(b[h])||[],j=k=i[1],l=i[2];if(!j){for(j in o)f.event.remove(a,j+b[h],c,d,!0);continue}p=f.event.special[j]||{},j=(d?p.delegateType:p.bindType)||j,r=o[j]||[],m=r.length,l=l?new RegExp("(^|\\.)"+l.split(".").sort().join("\\.(?:.*\\.)?")+"(\\.|$)"):null;for(n=0;n<r.length;n++)s=r[n],(e||k===s.origType)&&(!c||c.guid===s.guid)&&(!l||l.test(s.namespace))&&(!d||d===s.selector||d==="**"&&s.selector)&&(r.splice(n--,1),s.selector&&r.delegateCount--,p.remove&&p.remove.call(a,s));r.length===0&&m!==r.length&&((!p.teardown||p.teardown.call(a,l)===!1)&&f.removeEvent(a,j,g.handle),delete o[j])}f.isEmptyObject(o)&&(q=g.handle,q&&(q.elem=null),f.removeData(a,["events","handle"],!0))}},customEvent:{getData:!0,setData:!0,changeData:!0},trigger:function(c,d,e,g){if(!e||e.nodeType!==3&&e.nodeType!==8){var h=c.type||c,i=[],j,k,l,m,n,o,p,q,r,s;if(E.test(h+f.event.triggered))return;h.indexOf("!")>=0&&(h=h.slice(0,-1),k=!0),h.indexOf(".")>=0&&(i=h.split("."),h=i.shift(),i.sort());if((!e||f.event.customEvent[h])&&!f.event.global[h])return;c=typeof c=="object"?c[f.expando]?c:new f.Event(h,c):new f.Event(h),c.type=h,c.isTrigger=!0,c.exclusive=k,c.namespace=i.join("."),c.namespace_re=c.namespace?new RegExp("(^|\\.)"+i.join("\\.(?:.*\\.)?")+"(\\.|$)"):null,o=h.indexOf(":")<0?"on"+h:"";if(!e){j=f.cache;for(l in j)j[l].events&&j[l].events[h]&&f.event.trigger(c,d,j[l].handle.elem,!0);return}c.result=b,c.target||(c.target=e),d=d!=null?f.makeArray(d):[],d.unshift(c),p=f.event.special[h]||{};if(p.trigger&&p.trigger.apply(e,d)===!1)return;r=[[e,p.bindType||h]];if(!g&&!p.noBubble&&!f.isWindow(e)){s=p.delegateType||h,m=E.test(s+h)?e:e.parentNode,n=null;for(;m;m=m.parentNode)r.push([m,s]),n=m;n&&n===e.ownerDocument&&r.push([n.defaultView||n.parentWindow||a,s])}for(l=0;l<r.length&&!c.isPropagationStopped();l++)m=r[l][0],c.type=r[l][1],q=(f._data(m,"events")||{})[c.type]&&f._data(m,"handle"),q&&q.apply(m,d),q=o&&m[o],q&&f.acceptData(m)&&q.apply(m,d)===!1&&c.preventDefault();c.type=h,!g&&!c.isDefaultPrevented()&&(!p._default||p._default.apply(e.ownerDocument,d)===!1)&&(h!=="click"||!f.nodeName(e,"a"))&&f.acceptData(e)&&o&&e[h]&&(h!=="focus"&&h!=="blur"||c.target.offsetWidth!==0)&&!f.isWindow(e)&&(n=e[o],n&&(e[o]=null),f.event.triggered=h,e[h](),f.event.triggered=b,n&&(e[o]=n));return c.result}},dispatch:function(c){c=f.event.fix(c||a.event);var d=(f._data(this,"events")||{})[c.type]||[],e=d.delegateCount,g=[].slice.call(arguments,0),h=!c.exclusive&&!c.namespace,i=[],j,k,l,m,n,o,p,q,r,s,t;g[0]=c,c.delegateTarget=this;if(e&&!c.target.disabled&&(!c.button||c.type!=="click")){m=f(this),m.context=this.ownerDocument||this;for(l=c.target;l!=this;l=l.parentNode||this){o={},q=[],m[0]=l;for(j=0;j<e;j++)r=d[j],s=r.selector,o[s]===b&&(o[s]=r.quick?H(l,r.quick):m.is(s)),o[s]&&q.push(r);q.length&&i.push({elem:l,matches:q})}}d.length>e&&i.push({elem:this,matches:d.slice(e)});for(j=0;j<i.length&&!c.isPropagationStopped();j++){p=i[j],c.currentTarget=p.elem;for(k=0;k<p.matches.length&&!c.isImmediatePropagationStopped();k++){r=p.matches[k];if(h||!c.namespace&&!r.namespace||c.namespace_re&&c.namespace_re.test(r.namespace))c.data=r.data,c.handleObj=r,n=((f.event.special[r.origType]||{}).handle||r.handler).apply(p.elem,g),n!==b&&(c.result=n,n===!1&&(c.preventDefault(),c.stopPropagation()))}}return c.result},props:"attrChange attrName relatedNode srcElement altKey bubbles cancelable ctrlKey currentTarget eventPhase metaKey relatedTarget shiftKey target timeStamp view which".split(" "),fixHooks:{},keyHooks:{props:"char charCode key keyCode".split(" "),filter:function(a,b){a.which==null&&(a.which=b.charCode!=null?b.charCode:b.keyCode);return a}},mouseHooks:{props:"button buttons clientX clientY fromElement offsetX offsetY pageX pageY screenX screenY toElement".split(" "),filter:function(a,d){var e,f,g,h=d.button,i=d.fromElement;a.pageX==null&&d.clientX!=null&&(e=a.target.ownerDocument||c,f=e.documentElement,g=e.body,a.pageX=d.clientX+(f&&f.scrollLeft||g&&g.scrollLeft||0)-(f&&f.clientLeft||g&&g.clientLeft||0),a.pageY=d.clientY+(f&&f.scrollTop||g&&g.scrollTop||0)-(f&&f.clientTop||g&&g.clientTop||0)),!a.relatedTarget&&i&&(a.relatedTarget=i===a.target?d.toElement:i),!a.which&&h!==b&&(a.which=h&1?1:h&2?3:h&4?2:0);return a}},fix:function(a){if(a[f.expando])return a;var d,e,g=a,h=f.event.fixHooks[a.type]||{},i=h.props?this.props.concat(h.props):this.props;a=f.Event(g);for(d=i.length;d;)e=i[--d],a[e]=g[e];a.target||(a.target=g.srcElement||c),a.target.nodeType===3&&(a.target=a.target.parentNode),a.metaKey===b&&(a.metaKey=a.ctrlKey);return h.filter?h.filter(a,g):a},special:{ready:{setup:f.bindReady},load:{noBubble:!0},focus:{delegateType:"focusin"},blur:{delegateType:"focusout"},beforeunload:{setup:function(a,b,c){f.isWindow(this)&&(this.onbeforeunload=c)},teardown:function(a,b){this.onbeforeunload===b&&(this.onbeforeunload=null)}}},simulate:function(a,b,c,d){var e=f.extend(new f.Event,c,{type:a,isSimulated:!0,originalEvent:{}});d?f.event.trigger(e,null,b):f.event.dispatch.call(b,e),e.isDefaultPrevented()&&c.preventDefault()}},f.event.handle=f.event.dispatch,f.removeEvent=c.removeEventListener?function(a,b,c){a.removeEventListener&&a.removeEventListener(b,c,!1)}:function(a,b,c){a.detachEvent&&a.detachEvent("on"+b,c)},f.Event=function(a,b){if(!(this instanceof f.Event))return new f.Event(a,b);a&&a.type?(this.originalEvent=a,this.type=a.type,this.isDefaultPrevented=a.defaultPrevented||a.returnValue===!1||a.getPreventDefault&&a.getPreventDefault()?K:J):this.type=a,b&&f.extend(this,b),this.timeStamp=a&&a.timeStamp||f.now(),this[f.expando]=!0},f.Event.prototype={preventDefault:function(){this.isDefaultPrevented=K;var a=this.originalEvent;!a||(a.preventDefault?a.preventDefault():a.returnValue=!1)},stopPropagation:function(){this.isPropagationStopped=K;var a=this.originalEvent;!a||(a.stopPropagation&&a.stopPropagation(),a.cancelBubble=!0)},stopImmediatePropagation:function(){this.isImmediatePropagationStopped=K,this.stopPropagation()},isDefaultPrevented:J,isPropagationStopped:J,isImmediatePropagationStopped:J},f.each({mouseenter:"mouseover",mouseleave:"mouseout"},function(a,b){f.event.special[a]={delegateType:b,bindType:b,handle:function(a){var c=this,d=a.relatedTarget,e=a.handleObj,g=e.selector,h;if(!d||d!==c&&!f.contains(c,d))a.type=e.origType,h=e.handler.apply(this,arguments),a.type=b;return h}}}),f.support.submitBubbles||(f.event.special.submit={setup:function(){if(f.nodeName(this,"form"))return!1;f.event.add(this,"click._submit keypress._submit",function(a){var c=a.target,d=f.nodeName(c,"input")||f.nodeName(c,"button")?c.form:b;d&&!d._submit_attached&&(f.event.add(d,"submit._submit",function(a){this.parentNode&&!a.isTrigger&&f.event.simulate("submit",this.parentNode,a,!0)}),d._submit_attached=!0)})},teardown:function(){if(f.nodeName(this,"form"))return!1;f.event.remove(this,"._submit")}}),f.support.changeBubbles||(f.event.special.change={setup:function(){if(z.test(this.nodeName)){if(this.type==="checkbox"||this.type==="radio")f.event.add(this,"propertychange._change",function(a){a.originalEvent.propertyName==="checked"&&(this._just_changed=!0)}),f.event.add(this,"click._change",function(a){this._just_changed&&!a.isTrigger&&(this._just_changed=!1,f.event.simulate("change",this,a,!0))});return!1}f.event.add(this,"beforeactivate._change",function(a){var b=a.target;z.test(b.nodeName)&&!b._change_attached&&(f.event.add(b,"change._change",function(a){this.parentNode&&!a.isSimulated&&!a.isTrigger&&f.event.simulate("change",this.parentNode,a,!0)}),b._change_attached=!0)})},handle:function(a){var b=a.target;if(this!==b||a.isSimulated||a.isTrigger||b.type!=="radio"&&b.type!=="checkbox")return a.handleObj.handler.apply(this,arguments)},teardown:function(){f.event.remove(this,"._change");return z.test(this.nodeName)}}),f.support.focusinBubbles||f.each({focus:"focusin",blur:"focusout"},function(a,b){var d=0,e=function(a){f.event.simulate(b,a.target,f.event.fix(a),!0)};f.event.special[b]={setup:function(){d++===0&&c.addEventListener(a,e,!0)},teardown:function(){--d===0&&c.removeEventListener(a,e,!0)}}}),f.fn.extend({on:function(a,c,d,e,g){var h,i;if(typeof a=="object"){typeof c!="string"&&(d=c,c=b);for(i in a)this.on(i,c,d,a[i],g);return this}d==null&&e==null?(e=c,d=c=b):e==null&&(typeof c=="string"?(e=d,d=b):(e=d,d=c,c=b));if(e===!1)e=J;else if(!e)return this;g===1&&(h=e,e=function(a){f().off(a);return h.apply(this,arguments)},e.guid=h.guid||(h.guid=f.guid++));return this.each(function(){f.event.add(this,a,e,d,c)})},one:function(a,b,c,d){return this.on.call(this,a,b,c,d,1)},off:function(a,c,d){if(a&&a.preventDefault&&a.handleObj){var e=a.handleObj;f(a.delegateTarget).off(e.namespace?e.type+"."+e.namespace:e.type,e.selector,e.handler);return this}if(typeof a=="object"){for(var g in a)this.off(g,c,a[g]);return this}if(c===!1||typeof c=="function")d=c,c=b;d===!1&&(d=J);return this.each(function(){f.event.remove(this,a,d,c)})},bind:function(a,b,c){return this.on(a,null,b,c)},unbind:function(a,b){return this.off(a,null,b)},live:function(a,b,c){f(this.context).on(a,this.selector,b,c);return this},die:function(a,b){f(this.context).off(a,this.selector||"**",b);return this},delegate:function(a,b,c,d){return this.on(b,a,c,d)},undelegate:function(a,b,c){return arguments.length==1?this.off(a,"**"):this.off(b,a,c)},trigger:function(a,b){return this.each(function(){f.event.trigger(a,b,this)})},triggerHandler:function(a,b){if(this[0])return f.event.trigger(a,b,this[0],!0)},toggle:function(a){var b=arguments,c=a.guid||f.guid++,d=0,e=function(c){var e=(f._data(this,"lastToggle"+a.guid)||0)%d;f._data(this,"lastToggle"+a.guid,e+1),c.preventDefault();return b[e].apply(this,arguments)||!1};e.guid=c;while(d<b.length)b[d++].guid=c;return this.click(e)},hover:function(a,b){return this.mouseenter(a).mouseleave(b||a)}}),f.each("blur focus focusin focusout load resize scroll unload click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup error contextmenu".split(" "),function(a,b){f.fn[b]=function(a,c){c==null&&(c=a,a=null);return arguments.length>0?this.on(b,null,a,c):this.trigger(b)},f.attrFn&&(f.attrFn[b]=!0),C.test(b)&&(f.event.fixHooks[b]=f.event.keyHooks),D.test(b)&&(f.event.fixHooks[b]=f.event.mouseHooks)}),function(){function x(a,b,c,e,f,g){for(var h=0,i=e.length;h<i;h++){var j=e[h];if(j){var k=!1;j=j[a];while(j){if(j[d]===c){k=e[j.sizset];break}if(j.nodeType===1){g||(j[d]=c,j.sizset=h);if(typeof b!="string"){if(j===b){k=!0;break}}else if(m.filter(b,[j]).length>0){k=j;break}}j=j[a]}e[h]=k}}}function w(a,b,c,e,f,g){for(var h=0,i=e.length;h<i;h++){var j=e[h];if(j){var k=!1;j=j[a];while(j){if(j[d]===c){k=e[j.sizset];break}j.nodeType===1&&!g&&(j[d]=c,j.sizset=h);if(j.nodeName.toLowerCase()===b){k=j;break}j=j[a]}e[h]=k}}}var a=/((?:\((?:\([^()]+\)|[^()]+)+\)|\[(?:\[[^\[\]]*\]|['"][^'"]*['"]|[^\[\]'"]+)+\]|\\.|[^ >+~,(\[\\]+)+|[>+~])(\s*,\s*)?((?:.|\r|\n)*)/g,d="sizcache"+(Math.random()+"").replace(".",""),e=0,g=Object.prototype.toString,h=!1,i=!0,j=/\\/g,k=/\r\n/g,l=/\W/;[0,0].sort(function(){i=!1;return 0});var m=function(b,d,e,f){e=e||[],d=d||c;var h=d;if(d.nodeType!==1&&d.nodeType!==9)return[];if(!b||typeof b!="string")return e;var i,j,k,l,n,q,r,t,u=!0,v=m.isXML(d),w=[],x=b;do{a.exec(""),i=a.exec(x);if(i){x=i[3],w.push(i[1]);if(i[2]){l=i[3];break}}}while(i);if(w.length>1&&p.exec(b))if(w.length===2&&o.relative[w[0]])j=y(w[0]+w[1],d,f);else{j=o.relative[w[0]]?[d]:m(w.shift(),d);while(w.length)b=w.shift(),o.relative[b]&&(b+=w.shift()),j=y(b,j,f)}else{!f&&w.length>1&&d.nodeType===9&&!v&&o.match.ID.test(w[0])&&!o.match.ID.test(w[w.length-1])&&(n=m.find(w.shift(),d,v),d=n.expr?m.filter(n.expr,n.set)[0]:n.set[0]);if(d){n=f?{expr:w.pop(),set:s(f)}:m.find(w.pop(),w.length===1&&(w[0]==="~"||w[0]==="+")&&d.parentNode?d.parentNode:d,v),j=n.expr?m.filter(n.expr,n.set):n.set,w.length>0?k=s(j):u=!1;while(w.length)q=w.pop(),r=q,o.relative[q]?r=w.pop():q="",r==null&&(r=d),o.relative[q](k,r,v)}else k=w=[]}k||(k=j),k||m.error(q||b);if(g.call(k)==="[object Array]")if(!u)e.push.apply(e,k);else if(d&&d.nodeType===1)for(t=0;k[t]!=null;t++)k[t]&&(k[t]===!0||k[t].nodeType===1&&m.contains(d,k[t]))&&e.push(j[t]);else for(t=0;k[t]!=null;t++)k[t]&&k[t].nodeType===1&&e.push(j[t]);else s(k,e);l&&(m(l,h,e,f),m.uniqueSort(e));return e};m.uniqueSort=function(a){if(u){h=i,a.sort(u);if(h)for(var b=1;b<a.length;b++)a[b]===a[b-1]&&a.splice(b--,1)}return a},m.matches=function(a,b){return m(a,null,null,b)},m.matchesSelector=function(a,b){return m(b,null,null,[a]).length>0},m.find=function(a,b,c){var d,e,f,g,h,i;if(!a)return[];for(e=0,f=o.order.length;e<f;e++){h=o.order[e];if(g=o.leftMatch[h].exec(a)){i=g[1],g.splice(1,1);if(i.substr(i.length-1)!=="\\"){g[1]=(g[1]||"").replace(j,""),d=o.find[h](g,b,c);if(d!=null){a=a.replace(o.match[h],"");break}}}}d||(d=typeof b.getElementsByTagName!="undefined"?b.getElementsByTagName("*"):[]);return{set:d,expr:a}},m.filter=function(a,c,d,e){var f,g,h,i,j,k,l,n,p,q=a,r=[],s=c,t=c&&c[0]&&m.isXML(c[0]);while(a&&c.length){for(h in o.filter)if((f=o.leftMatch[h].exec(a))!=null&&f[2]){k=o.filter[h],l=f[1],g=!1,f.splice(1,1);if(l.substr(l.length-1)==="\\")continue;s===r&&(r=[]);if(o.preFilter[h]){f=o.preFilter[h](f,s,d,r,e,t);if(!f)g=i=!0;else if(f===!0)continue}if(f)for(n=0;(j=s[n])!=null;n++)j&&(i=k(j,f,n,s),p=e^i,d&&i!=null?p?g=!0:s[n]=!1:p&&(r.push(j),g=!0));if(i!==b){d||(s=r),a=a.replace(o.match[h],"");if(!g)return[];break}}if(a===q)if(g==null)m.error(a);else break;q=a}return s},m.error=function(a){throw new Error("Syntax error, unrecognized expression: "+a)};var n=m.getText=function(a){var b,c,d=a.nodeType,e="";if(d){if(d===1||d===9){if(typeof a.textContent=="string")return a.textContent;if(typeof a.innerText=="string")return a.innerText.replace(k,"");for(a=a.firstChild;a;a=a.nextSibling)e+=n(a)}else if(d===3||d===4)return a.nodeValue}else for(b=0;c=a[b];b++)c.nodeType!==8&&(e+=n(c));return e},o=m.selectors={order:["ID","NAME","TAG"],match:{ID:/#((?:[\w\u00c0-\uFFFF\-]|\\.)+)/,CLASS:/\.((?:[\w\u00c0-\uFFFF\-]|\\.)+)/,NAME:/\[name=['"]*((?:[\w\u00c0-\uFFFF\-]|\\.)+)['"]*\]/,ATTR:/\[\s*((?:[\w\u00c0-\uFFFF\-]|\\.)+)\s*(?:(\S?=)\s*(?:(['"])(.*?)\3|(#?(?:[\w\u00c0-\uFFFF\-]|\\.)*)|)|)\s*\]/,TAG:/^((?:[\w\u00c0-\uFFFF\*\-]|\\.)+)/,CHILD:/:(only|nth|last|first)-child(?:\(\s*(even|odd|(?:[+\-]?\d+|(?:[+\-]?\d*)?n\s*(?:[+\-]\s*\d+)?))\s*\))?/,POS:/:(nth|eq|gt|lt|first|last|even|odd)(?:\((\d*)\))?(?=[^\-]|$)/,PSEUDO:/:((?:[\w\u00c0-\uFFFF\-]|\\.)+)(?:\((['"]?)((?:\([^\)]+\)|[^\(\)]*)+)\2\))?/},leftMatch:{},attrMap:{"class":"className","for":"htmlFor"},attrHandle:{href:function(a){return a.getAttribute("href")},type:function(a){return a.getAttribute("type")}},relative:{"+":function(a,b){var c=typeof b=="string",d=c&&!l.test(b),e=c&&!d;d&&(b=b.toLowerCase());for(var f=0,g=a.length,h;f<g;f++)if(h=a[f]){while((h=h.previousSibling)&&h.nodeType!==1);a[f]=e||h&&h.nodeName.toLowerCase()===b?h||!1:h===b}e&&m.filter(b,a,!0)},">":function(a,b){var c,d=typeof b=="string",e=0,f=a.length;if(d&&!l.test(b)){b=b.toLowerCase();for(;e<f;e++){c=a[e];if(c){var g=c.parentNode;a[e]=g.nodeName.toLowerCase()===b?g:!1}}}else{for(;e<f;e++)c=a[e],c&&(a[e]=d?c.parentNode:c.parentNode===b);d&&m.filter(b,a,!0)}},"":function(a,b,c){var d,f=e++,g=x;typeof b=="string"&&!l.test(b)&&(b=b.toLowerCase(),d=b,g=w),g("parentNode",b,f,a,d,c)},"~":function(a,b,c){var d,f=e++,g=x;typeof b=="string"&&!l.test(b)&&(b=b.toLowerCase(),d=b,g=w),g("previousSibling",b,f,a,d,c)}},find:{ID:function(a,b,c){if(typeof b.getElementById!="undefined"&&!c){var d=b.getElementById(a[1]);return d&&d.parentNode?[d]:[]}},NAME:function(a,b){if(typeof b.getElementsByName!="undefined"){var c=[],d=b.getElementsByName(a[1]);for(var e=0,f=d.length;e<f;e++)d[e].getAttribute("name")===a[1]&&c.push(d[e]);return c.length===0?null:c}},TAG:function(a,b){if(typeof b.getElementsByTagName!="undefined")return b.getElementsByTagName(a[1])}},preFilter:{CLASS:function(a,b,c,d,e,f){a=" "+a[1].replace(j,"")+" ";if(f)return a;for(var g=0,h;(h=b[g])!=null;g++)h&&(e^(h.className&&(" "+h.className+" ").replace(/[\t\n\r]/g," ").indexOf(a)>=0)?c||d.push(h):c&&(b[g]=!1));return!1},ID:function(a){return a[1].replace(j,"")},TAG:function(a,b){return a[1].replace(j,"").toLowerCase()},CHILD:function(a){if(a[1]==="nth"){a[2]||m.error(a[0]),a[2]=a[2].replace(/^\+|\s*/g,"");var b=/(-?)(\d*)(?:n([+\-]?\d*))?/.exec(a[2]==="even"&&"2n"||a[2]==="odd"&&"2n+1"||!/\D/.test(a[2])&&"0n+"+a[2]||a[2]);a[2]=b[1]+(b[2]||1)-0,a[3]=b[3]-0}else a[2]&&m.error(a[0]);a[0]=e++;return a},ATTR:function(a,b,c,d,e,f){var g=a[1]=a[1].replace(j,"");!f&&o.attrMap[g]&&(a[1]=o.attrMap[g]),a[4]=(a[4]||a[5]||"").replace(j,""),a[2]==="~="&&(a[4]=" "+a[4]+" ");return a},PSEUDO:function(b,c,d,e,f){if(b[1]==="not")if((a.exec(b[3])||"").length>1||/^\w/.test(b[3]))b[3]=m(b[3],null,null,c);else{var g=m.filter(b[3],c,d,!0^f);d||e.push.apply(e,g);return!1}else if(o.match.POS.test(b[0])||o.match.CHILD.test(b[0]))return!0;return b},POS:function(a){a.unshift(!0);return a}},filters:{enabled:function(a){return a.disabled===!1&&a.type!=="hidden"},disabled:function(a){return a.disabled===!0},checked:function(a){return a.checked===!0},selected:function(a){a.parentNode&&a.parentNode.selectedIndex;return a.selected===!0},parent:function(a){return!!a.firstChild},empty:function(a){return!a.firstChild},has:function(a,b,c){return!!m(c[3],a).length},header:function(a){return/h\d/i.test(a.nodeName)},text:function(a){var b=a.getAttribute("type"),c=a.type;return a.nodeName.toLowerCase()==="input"&&"text"===c&&(b===c||b===null)},radio:function(a){return a.nodeName.toLowerCase()==="input"&&"radio"===a.type},checkbox:function(a){return a.nodeName.toLowerCase()==="input"&&"checkbox"===a.type},file:function(a){return a.nodeName.toLowerCase()==="input"&&"file"===a.type},password:function(a){return a.nodeName.toLowerCase()==="input"&&"password"===a.type},submit:function(a){var b=a.nodeName.toLowerCase();return(b==="input"||b==="button")&&"submit"===a.type},image:function(a){return a.nodeName.toLowerCase()==="input"&&"image"===a.type},reset:function(a){var b=a.nodeName.toLowerCase();return(b==="input"||b==="button")&&"reset"===a.type},button:function(a){var b=a.nodeName.toLowerCase();return b==="input"&&"button"===a.type||b==="button"},input:function(a){return/input|select|textarea|button/i.test(a.nodeName)},focus:function(a){return a===a.ownerDocument.activeElement}},setFilters:{first:function(a,b){return b===0},last:function(a,b,c,d){return b===d.length-1},even:function(a,b){return b%2===0},odd:function(a,b){return b%2===1},lt:function(a,b,c){return b<c[3]-0},gt:function(a,b,c){return b>c[3]-0},nth:function(a,b,c){return c[3]-0===b},eq:function(a,b,c){return c[3]-0===b}},filter:{PSEUDO:function(a,b,c,d){var e=b[1],f=o.filters[e];if(f)return f(a,c,b,d);if(e==="contains")return(a.textContent||a.innerText||n([a])||"").indexOf(b[3])>=0;if(e==="not"){var g=b[3];for(var h=0,i=g.length;h<i;h++)if(g[h]===a)return!1;return!0}m.error(e)},CHILD:function(a,b){var c,e,f,g,h,i,j,k=b[1],l=a;switch(k){case"only":case"first":while(l=l.previousSibling)if(l.nodeType===1)return!1;if(k==="first")return!0;l=a;case"last":while(l=l.nextSibling)if(l.nodeType===1)return!1;return!0;case"nth":c=b[2],e=b[3];if(c===1&&e===0)return!0;f=b[0],g=a.parentNode;if(g&&(g[d]!==f||!a.nodeIndex)){i=0;for(l=g.firstChild;l;l=l.nextSibling)l.nodeType===1&&(l.nodeIndex=++i);g[d]=f}j=a.nodeIndex-e;return c===0?j===0:j%c===0&&j/c>=0}},ID:function(a,b){return a.nodeType===1&&a.getAttribute("id")===b},TAG:function(a,b){return b==="*"&&a.nodeType===1||!!a.nodeName&&a.nodeName.toLowerCase()===b},CLASS:function(a,b){return(" "+(a.className||a.getAttribute("class"))+" ").indexOf(b)>-1},ATTR:function(a,b){var c=b[1],d=m.attr?m.attr(a,c):o.attrHandle[c]?o.attrHandle[c](a):a[c]!=null?a[c]:a.getAttribute(c),e=d+"",f=b[2],g=b[4];return d==null?f==="!=":!f&&m.attr?d!=null:f==="="?e===g:f==="*="?e.indexOf(g)>=0:f==="~="?(" "+e+" ").indexOf(g)>=0:g?f==="!="?e!==g:f==="^="?e.indexOf(g)===0:f==="$="?e.substr(e.length-g.length)===g:f==="|="?e===g||e.substr(0,g.length+1)===g+"-":!1:e&&d!==!1},POS:function(a,b,c,d){var e=b[2],f=o.setFilters[e];if(f)return f(a,c,b,d)}}},p=o.match.POS,q=function(a,b){return"\\"+(b-0+1)};for(var r in o.match)o.match[r]=new RegExp(o.match[r].source+/(?![^\[]*\])(?![^\(]*\))/.source),o.leftMatch[r]=new RegExp(/(^(?:.|\r|\n)*?)/.source+o.match[r].source.replace(/\\(\d+)/g,q));var s=function(a,b){a=Array.prototype.slice.call(a,0);if(b){b.push.apply(b,a);return b}return a};try{Array.prototype.slice.call(c.documentElement.childNodes,0)[0].nodeType}catch(t){s=function(a,b){var c=0,d=b||[];if(g.call(a)==="[object Array]")Array.prototype.push.apply(d,a);else if(typeof a.length=="number")for(var e=a.length;c<e;c++)d.push(a[c]);else for(;a[c];c++)d.push(a[c]);return d}}var u,v;c.documentElement.compareDocumentPosition?u=function(a,b){if(a===b){h=!0;return 0}if(!a.compareDocumentPosition||!b.compareDocumentPosition)return a.compareDocumentPosition?-1:1;return a.compareDocumentPosition(b)&4?-1:1}:(u=function(a,b){if(a===b){h=!0;return 0}if(a.sourceIndex&&b.sourceIndex)return a.sourceIndex-b.sourceIndex;var c,d,e=[],f=[],g=a.parentNode,i=b.parentNode,j=g;if(g===i)return v(a,b);if(!g)return-1;if(!i)return 1;while(j)e.unshift(j),j=j.parentNode;j=i;while(j)f.unshift(j),j=j.parentNode;c=e.length,d=f.length;for(var k=0;k<c&&k<d;k++)if(e[k]!==f[k])return v(e[k],f[k]);return k===c?v(a,f[k],-1):v(e[k],b,1)},v=function(a,b,c){if(a===b)return c;var d=a.nextSibling;while(d){if(d===b)return-1;d=d.nextSibling}return 1}),function(){var a=c.createElement("div"),d="script"+(new Date).getTime(),e=c.documentElement;a.innerHTML="<a name='"+d+"'/>",e.insertBefore(a,e.firstChild),c.getElementById(d)&&(o.find.ID=function(a,c,d){if(typeof c.getElementById!="undefined"&&!d){var e=c.getElementById(a[1]);return e?e.id===a[1]||typeof e.getAttributeNode!="undefined"&&e.getAttributeNode("id").nodeValue===a[1]?[e]:b:[]}},o.filter.ID=function(a,b){var c=typeof a.getAttributeNode!="undefined"&&a.getAttributeNode("id");return a.nodeType===1&&c&&c.nodeValue===b}),e.removeChild(a),e=a=null}(),function(){var a=c.createElement("div");a.appendChild(c.createComment("")),a.getElementsByTagName("*").length>0&&(o.find.TAG=function(a,b){var c=b.getElementsByTagName(a[1]);if(a[1]==="*"){var d=[];for(var e=0;c[e];e++)c[e].nodeType===1&&d.push(c[e]);c=d}return c}),a.innerHTML="<a href='#'></a>",a.firstChild&&typeof a.firstChild.getAttribute!="undefined"&&a.firstChild.getAttribute("href")!=="#"&&(o.attrHandle.href=function(a){return a.getAttribute("href",2)}),a=null}(),c.querySelectorAll&&function(){var a=m,b=c.createElement("div"),d="__sizzle__";b.innerHTML="<p class='TEST'></p>";if(!b.querySelectorAll||b.querySelectorAll(".TEST").length!==0){m=function(b,e,f,g){e=e||c;if(!g&&!m.isXML(e)){var h=/^(\w+$)|^\.([\w\-]+$)|^#([\w\-]+$)/.exec(b);if(h&&(e.nodeType===1||e.nodeType===9)){if(h[1])return s(e.getElementsByTagName(b),f);if(h[2]&&o.find.CLASS&&e.getElementsByClassName)return s(e.getElementsByClassName(h[2]),f)}if(e.nodeType===9){if(b==="body"&&e.body)return s([e.body],f);if(h&&h[3]){var i=e.getElementById(h[3]);if(!i||!i.parentNode)return s([],f);if(i.id===h[3])return s([i],f)}try{return s(e.querySelectorAll(b),f)}catch(j){}}else if(e.nodeType===1&&e.nodeName.toLowerCase()!=="object"){var k=e,l=e.getAttribute("id"),n=l||d,p=e.parentNode,q=/^\s*[+~]/.test(b);l?n=n.replace(/'/g,"\\$&"):e.setAttribute("id",n),q&&p&&(e=e.parentNode);try{if(!q||p)return s(e.querySelectorAll("[id='"+n+"'] "+b),f)}catch(r){}finally{l||k.removeAttribute("id")}}}return a(b,e,f,g)};for(var e in a)m[e]=a[e];b=null}}(),function(){var a=c.documentElement,b=a.matchesSelector||a.mozMatchesSelector||a.webkitMatchesSelector||a.msMatchesSelector;if(b){var d=!b.call(c.createElement("div"),"div"),e=!1;try{b.call(c.documentElement,"[test!='']:sizzle")}catch(f){e=!0}m.matchesSelector=function(a,c){c=c.replace(/\=\s*([^'"\]]*)\s*\]/g,"='$1']");if(!m.isXML(a))try{if(e||!o.match.PSEUDO.test(c)&&!/!=/.test(c)){var f=b.call(a,c);if(f||!d||a.document&&a.document.nodeType!==11)return f}}catch(g){}return m(c,null,null,[a]).length>0}}}(),function(){var a=c.createElement("div");a.innerHTML="<div class='test e'></div><div class='test'></div>";if(!!a.getElementsByClassName&&a.getElementsByClassName("e").length!==0){a.lastChild.className="e";if(a.getElementsByClassName("e").length===1)return;o.order.splice(1,0,"CLASS"),o.find.CLASS=function(a,b,c){if(typeof b.getElementsByClassName!="undefined"&&!c)return b.getElementsByClassName(a[1])},a=null}}(),c.documentElement.contains?m.contains=function(a,b){return a!==b&&(a.contains?a.contains(b):!0)}:c.documentElement.compareDocumentPosition?m.contains=function(a,b){return!!(a.compareDocumentPosition(b)&16)}:m.contains=function(){return!1},m.isXML=function(a){var b=(a?a.ownerDocument||a:0).documentElement;return b?b.nodeName!=="HTML":!1};var y=function(a,b,c){var d,e=[],f="",g=b.nodeType?[b]:b;while(d=o.match.PSEUDO.exec(a))f+=d[0],a=a.replace(o.match.PSEUDO,"");a=o.relative[a]?a+"*":a;for(var h=0,i=g.length;h<i;h++)m(a,g[h],e,c);return m.filter(f,e)};m.attr=f.attr,m.selectors.attrMap={},f.find=m,f.expr=m.selectors,f.expr[":"]=f.expr.filters,f.unique=m.uniqueSort,f.text=m.getText,f.isXMLDoc=m.isXML,f.contains=m.contains}();var L=/Until$/,M=/^(?:parents|prevUntil|prevAll)/,N=/,/,O=/^.[^:#\[\.,]*$/,P=Array.prototype.slice,Q=f.expr.match.POS,R={children:!0,contents:!0,next:!0,prev:!0};f.fn.extend({find:function(a){var b=this,c,d;if(typeof a!="string")return f(a).filter(function(){for(c=0,d=b.length;c<d;c++)if(f.contains(b[c],this))return!0});var e=this.pushStack("","find",a),g,h,i;for(c=0,d=this.length;c<d;c++){g=e.length,f.find(a,this[c],e);if(c>0)for(h=g;h<e.length;h++)for(i=0;i<g;i++)if(e[i]===e[h]){e.splice(h--,1);break}}return e},has:function(a){var b=f(a);return this.filter(function(){for(var a=0,c=b.length;a<c;a++)if(f.contains(this,b[a]))return!0})},not:function(a){return this.pushStack(T(this,a,!1),"not",a)},filter:function(a){return this.pushStack(T(this,a,!0),"filter",a)},is:function(a){return!!a&&(typeof a=="string"?Q.test(a)?f(a,this.context).index(this[0])>=0:f.filter(a,this).length>0:this.filter(a).length>0)},closest:function(a,b){var c=[],d,e,g=this[0];if(f.isArray(a)){var h=1;while(g&&g.ownerDocument&&g!==b){for(d=0;d<a.length;d++)f(g).is(a[d])&&c.push({selector:a[d],elem:g,level:h});g=g.parentNode,h++}return c}var i=Q.test(a)||typeof a!="string"?f(a,b||this.context):0;for(d=0,e=this.length;d<e;d++){g=this[d];while(g){if(i?i.index(g)>-1:f.find.matchesSelector(g,a)){c.push(g);break}g=g.parentNode;if(!g||!g.ownerDocument||g===b||g.nodeType===11)break}}c=c.length>1?f.unique(c):c;return this.pushStack(c,"closest",a)},index:function(a){if(!a)return this[0]&&this[0].parentNode?this.prevAll().length:-1;if(typeof a=="string")return f.inArray(this[0],f(a));return f.inArray(a.jquery?a[0]:a,this)},add:function(a,b){var c=typeof a=="string"?f(a,b):f.makeArray(a&&a.nodeType?[a]:a),d=f.merge(this.get(),c);return this.pushStack(S(c[0])||S(d[0])?d:f.unique(d))},andSelf:function(){return this.add(this.prevObject)}}),f.each({parent:function(a){var b=a.parentNode;return b&&b.nodeType!==11?b:null},parents:function(a){return f.dir(a,"parentNode")},parentsUntil:function(a,b,c){return f.dir(a,"parentNode",c)},next:function(a){return f.nth(a,2,"nextSibling")},prev:function(a){return f.nth(a,2,"previousSibling")},nextAll:function(a){return f.dir(a,"nextSibling")},prevAll:function(a){return f.dir(a,"previousSibling")},nextUntil:function(a,b,c){return f.dir(a,"nextSibling",c)},prevUntil:function(a,b,c){return f.dir(a,"previousSibling",c)},siblings:function(a){return f.sibling(a.parentNode.firstChild,a)},children:function(a){return f.sibling(a.firstChild)},contents:function(a){return f.nodeName(a,"iframe")?a.contentDocument||a.contentWindow.document:f.makeArray(a.childNodes)}},function(a,b){f.fn[a]=function(c,d){var e=f.map(this,b,c);L.test(a)||(d=c),d&&typeof d=="string"&&(e=f.filter(d,e)),e=this.length>1&&!R[a]?f.unique(e):e,(this.length>1||N.test(d))&&M.test(a)&&(e=e.reverse());return this.pushStack(e,a,P.call(arguments).join(","))}}),f.extend({filter:function(a,b,c){c&&(a=":not("+a+")");return b.length===1?f.find.matchesSelector(b[0],a)?[b[0]]:[]:f.find.matches(a,b)},dir:function(a,c,d){var e=[],g=a[c];while(g&&g.nodeType!==9&&(d===b||g.nodeType!==1||!f(g).is(d)))g.nodeType===1&&e.push(g),g=g[c];return e},nth:function(a,b,c,d){b=b||1;var e=0;for(;a;a=a[c])if(a.nodeType===1&&++e===b)break;return a},sibling:function(a,b){var c=[];for(;a;a=a.nextSibling)a.nodeType===1&&a!==b&&c.push(a);return c}});var V="abbr|article|aside|audio|canvas|datalist|details|figcaption|figure|footer|header|hgroup|mark|meter|nav|output|progress|section|summary|time|video",W=/ jQuery\d+="(?:\d+|null)"/g,X=/^\s+/,Y=/<(?!area|br|col|embed|hr|img|input|link|meta|param)(([\w:]+)[^>]*)\/>/ig,Z=/<([\w:]+)/,$=/<tbody/i,_=/<|&#?\w+;/,ba=/<(?:script|style)/i,bb=/<(?:script|object|embed|option|style)/i,bc=new RegExp("<(?:"+V+")","i"),bd=/checked\s*(?:[^=]|=\s*.checked.)/i,be=/\/(java|ecma)script/i,bf=/^\s*<!(?:\[CDATA\[|\-\-)/,bg={option:[1,"<select multiple='multiple'>","</select>"],legend:[1,"<fieldset>","</fieldset>"],thead:[1,"<table>","</table>"],tr:[2,"<table><tbody>","</tbody></table>"],td:[3,"<table><tbody><tr>","</tr></tbody></table>"],col:[2,"<table><tbody></tbody><colgroup>","</colgroup></table>"],area:[1,"<map>","</map>"],_default:[0,"",""]},bh=U(c);bg.optgroup=bg.option,bg.tbody=bg.tfoot=bg.colgroup=bg.caption=bg.thead,bg.th=bg.td,f.support.htmlSerialize||(bg._default=[1,"div<div>","</div>"]),f.fn.extend({text:function(a){if(f.isFunction(a))return this.each(function(b){var c=f(this);c.text(a.call(this,b,c.text()))});if(typeof a!="object"&&a!==b)return this.empty().append((this[0]&&this[0].ownerDocument||c).createTextNode(a));return f.text(this)},wrapAll:function(a){if(f.isFunction(a))return this.each(function(b){f(this).wrapAll(a.call(this,b))});if(this[0]){var b=f(a,this[0].ownerDocument).eq(0).clone(!0);this[0].parentNode&&b.insertBefore(this[0]),b.map(function(){var a=this;while(a.firstChild&&a.firstChild.nodeType===1)a=a.firstChild;return a}).append(this)}return this},wrapInner:function(a){if(f.isFunction(a))return this.each(function(b){f(this).wrapInner(a.call(this,b))});return this.each(function(){var b=f(this),c=b.contents();c.length?c.wrapAll(a):b.append(a)})},wrap:function(a){var b=f.isFunction(a);return this.each(function(c){f(this).wrapAll(b?a.call(this,c):a)})},unwrap:function(){return this.parent().each(function(){f.nodeName(this,"body")||f(this).replaceWith(this.childNodes)}).end()},append:function(){return this.domManip(arguments,!0,function(a){this.nodeType===1&&this.appendChild(a)})},prepend:function(){return this.domManip(arguments,!0,function(a){this.nodeType===1&&this.insertBefore(a,this.firstChild)})},before:function(){if(this[0]&&this[0].parentNode)return this.domManip(arguments,!1,function(a){this.parentNode.insertBefore(a,this)});if(arguments.length){var a=f.clean(arguments);a.push.apply(a,this.toArray());return this.pushStack(a,"before",arguments)}},after:function(){if(this[0]&&this[0].parentNode)return this.domManip(arguments,!1,function(a){this.parentNode.insertBefore(a,this.nextSibling)});if(arguments.length){var a=this.pushStack(this,"after",arguments);a.push.apply(a,f.clean(arguments));return a}},remove:function(a,b){for(var c=0,d;(d=this[c])!=null;c++)if(!a||f.filter(a,[d]).length)!b&&d.nodeType===1&&(f.cleanData(d.getElementsByTagName("*")),f.cleanData([d])),d.parentNode&&d.parentNode.removeChild(d);return this},empty:function()
{for(var a=0,b;(b=this[a])!=null;a++){b.nodeType===1&&f.cleanData(b.getElementsByTagName("*"));while(b.firstChild)b.removeChild(b.firstChild)}return this},clone:function(a,b){a=a==null?!1:a,b=b==null?a:b;return this.map(function(){return f.clone(this,a,b)})},html:function(a){if(a===b)return this[0]&&this[0].nodeType===1?this[0].innerHTML.replace(W,""):null;if(typeof a=="string"&&!ba.test(a)&&(f.support.leadingWhitespace||!X.test(a))&&!bg[(Z.exec(a)||["",""])[1].toLowerCase()]){a=a.replace(Y,"<$1></$2>");try{for(var c=0,d=this.length;c<d;c++)this[c].nodeType===1&&(f.cleanData(this[c].getElementsByTagName("*")),this[c].innerHTML=a)}catch(e){this.empty().append(a)}}else f.isFunction(a)?this.each(function(b){var c=f(this);c.html(a.call(this,b,c.html()))}):this.empty().append(a);return this},replaceWith:function(a){if(this[0]&&this[0].parentNode){if(f.isFunction(a))return this.each(function(b){var c=f(this),d=c.html();c.replaceWith(a.call(this,b,d))});typeof a!="string"&&(a=f(a).detach());return this.each(function(){var b=this.nextSibling,c=this.parentNode;f(this).remove(),b?f(b).before(a):f(c).append(a)})}return this.length?this.pushStack(f(f.isFunction(a)?a():a),"replaceWith",a):this},detach:function(a){return this.remove(a,!0)},domManip:function(a,c,d){var e,g,h,i,j=a[0],k=[];if(!f.support.checkClone&&arguments.length===3&&typeof j=="string"&&bd.test(j))return this.each(function(){f(this).domManip(a,c,d,!0)});if(f.isFunction(j))return this.each(function(e){var g=f(this);a[0]=j.call(this,e,c?g.html():b),g.domManip(a,c,d)});if(this[0]){i=j&&j.parentNode,f.support.parentNode&&i&&i.nodeType===11&&i.childNodes.length===this.length?e={fragment:i}:e=f.buildFragment(a,this,k),h=e.fragment,h.childNodes.length===1?g=h=h.firstChild:g=h.firstChild;if(g){c=c&&f.nodeName(g,"tr");for(var l=0,m=this.length,n=m-1;l<m;l++)d.call(c?bi(this[l],g):this[l],e.cacheable||m>1&&l<n?f.clone(h,!0,!0):h)}k.length&&f.each(k,bp)}return this}}),f.buildFragment=function(a,b,d){var e,g,h,i,j=a[0];b&&b[0]&&(i=b[0].ownerDocument||b[0]),i.createDocumentFragment||(i=c),a.length===1&&typeof j=="string"&&j.length<512&&i===c&&j.charAt(0)==="<"&&!bb.test(j)&&(f.support.checkClone||!bd.test(j))&&(f.support.html5Clone||!bc.test(j))&&(g=!0,h=f.fragments[j],h&&h!==1&&(e=h)),e||(e=i.createDocumentFragment(),f.clean(a,i,e,d)),g&&(f.fragments[j]=h?e:1);return{fragment:e,cacheable:g}},f.fragments={},f.each({appendTo:"append",prependTo:"prepend",insertBefore:"before",insertAfter:"after",replaceAll:"replaceWith"},function(a,b){f.fn[a]=function(c){var d=[],e=f(c),g=this.length===1&&this[0].parentNode;if(g&&g.nodeType===11&&g.childNodes.length===1&&e.length===1){e[b](this[0]);return this}for(var h=0,i=e.length;h<i;h++){var j=(h>0?this.clone(!0):this).get();f(e[h])[b](j),d=d.concat(j)}return this.pushStack(d,a,e.selector)}}),f.extend({clone:function(a,b,c){var d,e,g,h=f.support.html5Clone||!bc.test("<"+a.nodeName)?a.cloneNode(!0):bo(a);if((!f.support.noCloneEvent||!f.support.noCloneChecked)&&(a.nodeType===1||a.nodeType===11)&&!f.isXMLDoc(a)){bk(a,h),d=bl(a),e=bl(h);for(g=0;d[g];++g)e[g]&&bk(d[g],e[g])}if(b){bj(a,h);if(c){d=bl(a),e=bl(h);for(g=0;d[g];++g)bj(d[g],e[g])}}d=e=null;return h},clean:function(a,b,d,e){var g;b=b||c,typeof b.createElement=="undefined"&&(b=b.ownerDocument||b[0]&&b[0].ownerDocument||c);var h=[],i;for(var j=0,k;(k=a[j])!=null;j++){typeof k=="number"&&(k+="");if(!k)continue;if(typeof k=="string")if(!_.test(k))k=b.createTextNode(k);else{k=k.replace(Y,"<$1></$2>");var l=(Z.exec(k)||["",""])[1].toLowerCase(),m=bg[l]||bg._default,n=m[0],o=b.createElement("div");b===c?bh.appendChild(o):U(b).appendChild(o),o.innerHTML=m[1]+k+m[2];while(n--)o=o.lastChild;if(!f.support.tbody){var p=$.test(k),q=l==="table"&&!p?o.firstChild&&o.firstChild.childNodes:m[1]==="<table>"&&!p?o.childNodes:[];for(i=q.length-1;i>=0;--i)f.nodeName(q[i],"tbody")&&!q[i].childNodes.length&&q[i].parentNode.removeChild(q[i])}!f.support.leadingWhitespace&&X.test(k)&&o.insertBefore(b.createTextNode(X.exec(k)[0]),o.firstChild),k=o.childNodes}var r;if(!f.support.appendChecked)if(k[0]&&typeof (r=k.length)=="number")for(i=0;i<r;i++)bn(k[i]);else bn(k);k.nodeType?h.push(k):h=f.merge(h,k)}if(d){g=function(a){return!a.type||be.test(a.type)};for(j=0;h[j];j++)if(e&&f.nodeName(h[j],"script")&&(!h[j].type||h[j].type.toLowerCase()==="text/javascript"))e.push(h[j].parentNode?h[j].parentNode.removeChild(h[j]):h[j]);else{if(h[j].nodeType===1){var s=f.grep(h[j].getElementsByTagName("script"),g);h.splice.apply(h,[j+1,0].concat(s))}d.appendChild(h[j])}}return h},cleanData:function(a){var b,c,d=f.cache,e=f.event.special,g=f.support.deleteExpando;for(var h=0,i;(i=a[h])!=null;h++){if(i.nodeName&&f.noData[i.nodeName.toLowerCase()])continue;c=i[f.expando];if(c){b=d[c];if(b&&b.events){for(var j in b.events)e[j]?f.event.remove(i,j):f.removeEvent(i,j,b.handle);b.handle&&(b.handle.elem=null)}g?delete i[f.expando]:i.removeAttribute&&i.removeAttribute(f.expando),delete d[c]}}}});var bq=/alpha\([^)]*\)/i,br=/opacity=([^)]*)/,bs=/([A-Z]|^ms)/g,bt=/^-?\d+(?:px)?$/i,bu=/^-?\d/,bv=/^([\-+])=([\-+.\de]+)/,bw={position:"absolute",visibility:"hidden",display:"block"},bx=["Left","Right"],by=["Top","Bottom"],bz,bA,bB;f.fn.css=function(a,c){if(arguments.length===2&&c===b)return this;return f.access(this,a,c,!0,function(a,c,d){return d!==b?f.style(a,c,d):f.css(a,c)})},f.extend({cssHooks:{opacity:{get:function(a,b){if(b){var c=bz(a,"opacity","opacity");return c===""?"1":c}return a.style.opacity}}},cssNumber:{fillOpacity:!0,fontWeight:!0,lineHeight:!0,opacity:!0,orphans:!0,widows:!0,zIndex:!0,zoom:!0},cssProps:{"float":f.support.cssFloat?"cssFloat":"styleFloat"},style:function(a,c,d,e){if(!!a&&a.nodeType!==3&&a.nodeType!==8&&!!a.style){var g,h,i=f.camelCase(c),j=a.style,k=f.cssHooks[i];c=f.cssProps[i]||i;if(d===b){if(k&&"get"in k&&(g=k.get(a,!1,e))!==b)return g;return j[c]}h=typeof d,h==="string"&&(g=bv.exec(d))&&(d=+(g[1]+1)*+g[2]+parseFloat(f.css(a,c)),h="number");if(d==null||h==="number"&&isNaN(d))return;h==="number"&&!f.cssNumber[i]&&(d+="px");if(!k||!("set"in k)||(d=k.set(a,d))!==b)try{j[c]=d}catch(l){}}},css:function(a,c,d){var e,g;c=f.camelCase(c),g=f.cssHooks[c],c=f.cssProps[c]||c,c==="cssFloat"&&(c="float");if(g&&"get"in g&&(e=g.get(a,!0,d))!==b)return e;if(bz)return bz(a,c)},swap:function(a,b,c){var d={};for(var e in b)d[e]=a.style[e],a.style[e]=b[e];c.call(a);for(e in b)a.style[e]=d[e]}}),f.curCSS=f.css,f.each(["height","width"],function(a,b){f.cssHooks[b]={get:function(a,c,d){var e;if(c){if(a.offsetWidth!==0)return bC(a,b,d);f.swap(a,bw,function(){e=bC(a,b,d)});return e}},set:function(a,b){if(!bt.test(b))return b;b=parseFloat(b);if(b>=0)return b+"px"}}}),f.support.opacity||(f.cssHooks.opacity={get:function(a,b){return br.test((b&&a.currentStyle?a.currentStyle.filter:a.style.filter)||"")?parseFloat(RegExp.$1)/100+"":b?"1":""},set:function(a,b){var c=a.style,d=a.currentStyle,e=f.isNumeric(b)?"alpha(opacity="+b*100+")":"",g=d&&d.filter||c.filter||"";c.zoom=1;if(b>=1&&f.trim(g.replace(bq,""))===""){c.removeAttribute("filter");if(d&&!d.filter)return}c.filter=bq.test(g)?g.replace(bq,e):g+" "+e}}),f(function(){f.support.reliableMarginRight||(f.cssHooks.marginRight={get:function(a,b){var c;f.swap(a,{display:"inline-block"},function(){b?c=bz(a,"margin-right","marginRight"):c=a.style.marginRight});return c}})}),c.defaultView&&c.defaultView.getComputedStyle&&(bA=function(a,b){var c,d,e;b=b.replace(bs,"-$1").toLowerCase(),(d=a.ownerDocument.defaultView)&&(e=d.getComputedStyle(a,null))&&(c=e.getPropertyValue(b),c===""&&!f.contains(a.ownerDocument.documentElement,a)&&(c=f.style(a,b)));return c}),c.documentElement.currentStyle&&(bB=function(a,b){var c,d,e,f=a.currentStyle&&a.currentStyle[b],g=a.style;f===null&&g&&(e=g[b])&&(f=e),!bt.test(f)&&bu.test(f)&&(c=g.left,d=a.runtimeStyle&&a.runtimeStyle.left,d&&(a.runtimeStyle.left=a.currentStyle.left),g.left=b==="fontSize"?"1em":f||0,f=g.pixelLeft+"px",g.left=c,d&&(a.runtimeStyle.left=d));return f===""?"auto":f}),bz=bA||bB,f.expr&&f.expr.filters&&(f.expr.filters.hidden=function(a){var b=a.offsetWidth,c=a.offsetHeight;return b===0&&c===0||!f.support.reliableHiddenOffsets&&(a.style&&a.style.display||f.css(a,"display"))==="none"},f.expr.filters.visible=function(a){return!f.expr.filters.hidden(a)});var bD=/%20/g,bE=/\[\]$/,bF=/\r?\n/g,bG=/#.*$/,bH=/^(.*?):[ \t]*([^\r\n]*)\r?$/mg,bI=/^(?:color|date|datetime|datetime-local|email|hidden|month|number|password|range|search|tel|text|time|url|week)$/i,bJ=/^(?:about|app|app\-storage|.+\-extension|file|res|widget):$/,bK=/^(?:GET|HEAD)$/,bL=/^\/\//,bM=/\?/,bN=/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi,bO=/^(?:select|textarea)/i,bP=/\s+/,bQ=/([?&])_=[^&]*/,bR=/^([\w\+\.\-]+:)(?:\/\/([^\/?#:]*)(?::(\d+))?)?/,bS=f.fn.load,bT={},bU={},bV,bW,bX=["*/"]+["*"];try{bV=e.href}catch(bY){bV=c.createElement("a"),bV.href="",bV=bV.href}bW=bR.exec(bV.toLowerCase())||[],f.fn.extend({load:function(a,c,d){if(typeof a!="string"&&bS)return bS.apply(this,arguments);if(!this.length)return this;var e=a.indexOf(" ");if(e>=0){var g=a.slice(e,a.length);a=a.slice(0,e)}var h="GET";c&&(f.isFunction(c)?(d=c,c=b):typeof c=="object"&&(c=f.param(c,f.ajaxSettings.traditional),h="POST"));var i=this;f.ajax({url:a,type:h,dataType:"html",data:c,complete:function(a,b,c){c=a.responseText,a.isResolved()&&(a.done(function(a){c=a}),i.html(g?f("<div>").append(c.replace(bN,"")).find(g):c)),d&&i.each(d,[c,b,a])}});return this},serialize:function(){return f.param(this.serializeArray())},serializeArray:function(){return this.map(function(){return this.elements?f.makeArray(this.elements):this}).filter(function(){return this.name&&!this.disabled&&(this.checked||bO.test(this.nodeName)||bI.test(this.type))}).map(function(a,b){var c=f(this).val();return c==null?null:f.isArray(c)?f.map(c,function(a,c){return{name:b.name,value:a.replace(bF,"\r\n")}}):{name:b.name,value:c.replace(bF,"\r\n")}}).get()}}),f.each("ajaxStart ajaxStop ajaxComplete ajaxError ajaxSuccess ajaxSend".split(" "),function(a,b){f.fn[b]=function(a){return this.on(b,a)}}),f.each(["get","post"],function(a,c){f[c]=function(a,d,e,g){f.isFunction(d)&&(g=g||e,e=d,d=b);return f.ajax({type:c,url:a,data:d,success:e,dataType:g})}}),f.extend({getScript:function(a,c){return f.get(a,b,c,"script")},getJSON:function(a,b,c){return f.get(a,b,c,"json")},ajaxSetup:function(a,b){b?b_(a,f.ajaxSettings):(b=a,a=f.ajaxSettings),b_(a,b);return a},ajaxSettings:{url:bV,isLocal:bJ.test(bW[1]),global:!0,type:"GET",contentType:"application/x-www-form-urlencoded",processData:!0,async:!0,accepts:{xml:"application/xml, text/xml",html:"text/html",text:"text/plain",json:"application/json, text/javascript","*":bX},contents:{xml:/xml/,html:/html/,json:/json/},responseFields:{xml:"responseXML",text:"responseText"},converters:{"* text":a.String,"text html":!0,"text json":f.parseJSON,"text xml":f.parseXML},flatOptions:{context:!0,url:!0}},ajaxPrefilter:bZ(bT),ajaxTransport:bZ(bU),ajax:function(a,c){function w(a,c,l,m){if(s!==2){s=2,q&&clearTimeout(q),p=b,n=m||"",v.readyState=a>0?4:0;var o,r,u,w=c,x=l?cb(d,v,l):b,y,z;if(a>=200&&a<300||a===304){if(d.ifModified){if(y=v.getResponseHeader("Last-Modified"))f.lastModified[k]=y;if(z=v.getResponseHeader("Etag"))f.etag[k]=z}if(a===304)w="notmodified",o=!0;else try{r=cc(d,x),w="success",o=!0}catch(A){w="parsererror",u=A}}else{u=w;if(!w||a)w="error",a<0&&(a=0)}v.status=a,v.statusText=""+(c||w),o?h.resolveWith(e,[r,w,v]):h.rejectWith(e,[v,w,u]),v.statusCode(j),j=b,t&&g.trigger("ajax"+(o?"Success":"Error"),[v,d,o?r:u]),i.fireWith(e,[v,w]),t&&(g.trigger("ajaxComplete",[v,d]),--f.active||f.event.trigger("ajaxStop"))}}typeof a=="object"&&(c=a,a=b),c=c||{};var d=f.ajaxSetup({},c),e=d.context||d,g=e!==d&&(e.nodeType||e instanceof f)?f(e):f.event,h=f.Deferred(),i=f.Callbacks("once memory"),j=d.statusCode||{},k,l={},m={},n,o,p,q,r,s=0,t,u,v={readyState:0,setRequestHeader:function(a,b){if(!s){var c=a.toLowerCase();a=m[c]=m[c]||a,l[a]=b}return this},getAllResponseHeaders:function(){return s===2?n:null},getResponseHeader:function(a){var c;if(s===2){if(!o){o={};while(c=bH.exec(n))o[c[1].toLowerCase()]=c[2]}c=o[a.toLowerCase()]}return c===b?null:c},overrideMimeType:function(a){s||(d.mimeType=a);return this},abort:function(a){a=a||"abort",p&&p.abort(a),w(0,a);return this}};h.promise(v),v.success=v.done,v.error=v.fail,v.complete=i.add,v.statusCode=function(a){if(a){var b;if(s<2)for(b in a)j[b]=[j[b],a[b]];else b=a[v.status],v.then(b,b)}return this},d.url=((a||d.url)+"").replace(bG,"").replace(bL,bW[1]+"//"),d.dataTypes=f.trim(d.dataType||"*").toLowerCase().split(bP),d.crossDomain==null&&(r=bR.exec(d.url.toLowerCase()),d.crossDomain=!(!r||r[1]==bW[1]&&r[2]==bW[2]&&(r[3]||(r[1]==="http:"?80:443))==(bW[3]||(bW[1]==="http:"?80:443)))),d.data&&d.processData&&typeof d.data!="string"&&(d.data=f.param(d.data,d.traditional)),b$(bT,d,c,v);if(s===2)return!1;t=d.global,d.type=d.type.toUpperCase(),d.hasContent=!bK.test(d.type),t&&f.active++===0&&f.event.trigger("ajaxStart");if(!d.hasContent){d.data&&(d.url+=(bM.test(d.url)?"&":"?")+d.data,delete d.data),k=d.url;if(d.cache===!1){var x=f.now(),y=d.url.replace(bQ,"$1_="+x);d.url=y+(y===d.url?(bM.test(d.url)?"&":"?")+"_="+x:"")}}(d.data&&d.hasContent&&d.contentType!==!1||c.contentType)&&v.setRequestHeader("Content-Type",d.contentType),d.ifModified&&(k=k||d.url,f.lastModified[k]&&v.setRequestHeader("If-Modified-Since",f.lastModified[k]),f.etag[k]&&v.setRequestHeader("If-None-Match",f.etag[k])),v.setRequestHeader("Accept",d.dataTypes[0]&&d.accepts[d.dataTypes[0]]?d.accepts[d.dataTypes[0]]+(d.dataTypes[0]!=="*"?", "+bX+"; q=0.01":""):d.accepts["*"]);for(u in d.headers)v.setRequestHeader(u,d.headers[u]);if(d.beforeSend&&(d.beforeSend.call(e,v,d)===!1||s===2)){v.abort();return!1}for(u in{success:1,error:1,complete:1})v[u](d[u]);p=b$(bU,d,c,v);if(!p)w(-1,"No Transport");else{v.readyState=1,t&&g.trigger("ajaxSend",[v,d]),d.async&&d.timeout>0&&(q=setTimeout(function(){v.abort("timeout")},d.timeout));try{s=1,p.send(l,w)}catch(z){if(s<2)w(-1,z);else throw z}}return v},param:function(a,c){var d=[],e=function(a,b){b=f.isFunction(b)?b():b,d[d.length]=encodeURIComponent(a)+"="+encodeURIComponent(b)};c===b&&(c=f.ajaxSettings.traditional);if(f.isArray(a)||a.jquery&&!f.isPlainObject(a))f.each(a,function(){e(this.name,this.value)});else for(var g in a)ca(g,a[g],c,e);return d.join("&").replace(bD,"+")}}),f.extend({active:0,lastModified:{},etag:{}});var cd=f.now(),ce=/(\=)\?(&|$)|\?\?/i;f.ajaxSetup({jsonp:"callback",jsonpCallback:function(){return f.expando+"_"+cd++}}),f.ajaxPrefilter("json jsonp",function(b,c,d){var e=b.contentType==="application/x-www-form-urlencoded"&&typeof b.data=="string";if(b.dataTypes[0]==="jsonp"||b.jsonp!==!1&&(ce.test(b.url)||e&&ce.test(b.data))){var g,h=b.jsonpCallback=f.isFunction(b.jsonpCallback)?b.jsonpCallback():b.jsonpCallback,i=a[h],j=b.url,k=b.data,l="$1"+h+"$2";b.jsonp!==!1&&(j=j.replace(ce,l),b.url===j&&(e&&(k=k.replace(ce,l)),b.data===k&&(j+=(/\?/.test(j)?"&":"?")+b.jsonp+"="+h))),b.url=j,b.data=k,a[h]=function(a){g=[a]},d.always(function(){a[h]=i,g&&f.isFunction(i)&&a[h](g[0])}),b.converters["script json"]=function(){g||f.error(h+" was not called");return g[0]},b.dataTypes[0]="json";return"script"}}),f.ajaxSetup({accepts:{script:"text/javascript, application/javascript, application/ecmascript, application/x-ecmascript"},contents:{script:/javascript|ecmascript/},converters:{"text script":function(a){f.globalEval(a);return a}}}),f.ajaxPrefilter("script",function(a){a.cache===b&&(a.cache=!1),a.crossDomain&&(a.type="GET",a.global=!1)}),f.ajaxTransport("script",function(a){if(a.crossDomain){var d,e=c.head||c.getElementsByTagName("head")[0]||c.documentElement;return{send:function(f,g){d=c.createElement("script"),d.async="async",a.scriptCharset&&(d.charset=a.scriptCharset),d.src=a.url,d.onload=d.onreadystatechange=function(a,c){if(c||!d.readyState||/loaded|complete/.test(d.readyState))d.onload=d.onreadystatechange=null,e&&d.parentNode&&e.removeChild(d),d=b,c||g(200,"success")},e.insertBefore(d,e.firstChild)},abort:function(){d&&d.onload(0,1)}}}});var cf=a.ActiveXObject?function(){for(var a in ch)ch[a](0,1)}:!1,cg=0,ch;f.ajaxSettings.xhr=a.ActiveXObject?function(){return!this.isLocal&&ci()||cj()}:ci,function(a){f.extend(f.support,{ajax:!!a,cors:!!a&&"withCredentials"in a})}(f.ajaxSettings.xhr()),f.support.ajax&&f.ajaxTransport(function(c){if(!c.crossDomain||f.support.cors){var d;return{send:function(e,g){var h=c.xhr(),i,j;c.username?h.open(c.type,c.url,c.async,c.username,c.password):h.open(c.type,c.url,c.async);if(c.xhrFields)for(j in c.xhrFields)h[j]=c.xhrFields[j];c.mimeType&&h.overrideMimeType&&h.overrideMimeType(c.mimeType),!c.crossDomain&&!e["X-Requested-With"]&&(e["X-Requested-With"]="XMLHttpRequest");try{for(j in e)h.setRequestHeader(j,e[j])}catch(k){}h.send(c.hasContent&&c.data||null),d=function(a,e){var j,k,l,m,n;try{if(d&&(e||h.readyState===4)){d=b,i&&(h.onreadystatechange=f.noop,cf&&delete ch[i]);if(e)h.readyState!==4&&h.abort();else{j=h.status,l=h.getAllResponseHeaders(),m={},n=h.responseXML,n&&n.documentElement&&(m.xml=n),m.text=h.responseText;try{k=h.statusText}catch(o){k=""}!j&&c.isLocal&&!c.crossDomain?j=m.text?200:404:j===1223&&(j=204)}}}catch(p){e||g(-1,p)}m&&g(j,k,m,l)},!c.async||h.readyState===4?d():(i=++cg,cf&&(ch||(ch={},f(a).unload(cf)),ch[i]=d),h.onreadystatechange=d)},abort:function(){d&&d(0,1)}}}});var ck={},cl,cm,cn=/^(?:toggle|show|hide)$/,co=/^([+\-]=)?([\d+.\-]+)([a-z%]*)$/i,cp,cq=[["height","marginTop","marginBottom","paddingTop","paddingBottom"],["width","marginLeft","marginRight","paddingLeft","paddingRight"],["opacity"]],cr;f.fn.extend({show:function(a,b,c){var d,e;if(a||a===0)return this.animate(cu("show",3),a,b,c);for(var g=0,h=this.length;g<h;g++)d=this[g],d.style&&(e=d.style.display,!f._data(d,"olddisplay")&&e==="none"&&(e=d.style.display=""),e===""&&f.css(d,"display")==="none"&&f._data(d,"olddisplay",cv(d.nodeName)));for(g=0;g<h;g++){d=this[g];if(d.style){e=d.style.display;if(e===""||e==="none")d.style.display=f._data(d,"olddisplay")||""}}return this},hide:function(a,b,c){if(a||a===0)return this.animate(cu("hide",3),a,b,c);var d,e,g=0,h=this.length;for(;g<h;g++)d=this[g],d.style&&(e=f.css(d,"display"),e!=="none"&&!f._data(d,"olddisplay")&&f._data(d,"olddisplay",e));for(g=0;g<h;g++)this[g].style&&(this[g].style.display="none");return this},_toggle:f.fn.toggle,toggle:function(a,b,c){var d=typeof a=="boolean";f.isFunction(a)&&f.isFunction(b)?this._toggle.apply(this,arguments):a==null||d?this.each(function(){var b=d?a:f(this).is(":hidden");f(this)[b?"show":"hide"]()}):this.animate(cu("toggle",3),a,b,c);return this},fadeTo:function(a,b,c,d){return this.filter(":hidden").css("opacity",0).show().end().animate({opacity:b},a,c,d)},animate:function(a,b,c,d){function g(){e.queue===!1&&f._mark(this);var b=f.extend({},e),c=this.nodeType===1,d=c&&f(this).is(":hidden"),g,h,i,j,k,l,m,n,o;b.animatedProperties={};for(i in a){g=f.camelCase(i),i!==g&&(a[g]=a[i],delete a[i]),h=a[g],f.isArray(h)?(b.animatedProperties[g]=h[1],h=a[g]=h[0]):b.animatedProperties[g]=b.specialEasing&&b.specialEasing[g]||b.easing||"swing";if(h==="hide"&&d||h==="show"&&!d)return b.complete.call(this);c&&(g==="height"||g==="width")&&(b.overflow=[this.style.overflow,this.style.overflowX,this.style.overflowY],f.css(this,"display")==="inline"&&f.css(this,"float")==="none"&&(!f.support.inlineBlockNeedsLayout||cv(this.nodeName)==="inline"?this.style.display="inline-block":this.style.zoom=1))}b.overflow!=null&&(this.style.overflow="hidden");for(i in a)j=new f.fx(this,b,i),h=a[i],cn.test(h)?(o=f._data(this,"toggle"+i)||(h==="toggle"?d?"show":"hide":0),o?(f._data(this,"toggle"+i,o==="show"?"hide":"show"),j[o]()):j[h]()):(k=co.exec(h),l=j.cur(),k?(m=parseFloat(k[2]),n=k[3]||(f.cssNumber[i]?"":"px"),n!=="px"&&(f.style(this,i,(m||1)+n),l=(m||1)/j.cur()*l,f.style(this,i,l+n)),k[1]&&(m=(k[1]==="-="?-1:1)*m+l),j.custom(l,m,n)):j.custom(l,h,""));return!0}var e=f.speed(b,c,d);if(f.isEmptyObject(a))return this.each(e.complete,[!1]);a=f.extend({},a);return e.queue===!1?this.each(g):this.queue(e.queue,g)},stop:function(a,c,d){typeof a!="string"&&(d=c,c=a,a=b),c&&a!==!1&&this.queue(a||"fx",[]);return this.each(function(){function h(a,b,c){var e=b[c];f.removeData(a,c,!0),e.stop(d)}var b,c=!1,e=f.timers,g=f._data(this);d||f._unmark(!0,this);if(a==null)for(b in g)g[b]&&g[b].stop&&b.indexOf(".run")===b.length-4&&h(this,g,b);else g[b=a+".run"]&&g[b].stop&&h(this,g,b);for(b=e.length;b--;)e[b].elem===this&&(a==null||e[b].queue===a)&&(d?e[b](!0):e[b].saveState(),c=!0,e.splice(b,1));(!d||!c)&&f.dequeue(this,a)})}}),f.each({slideDown:cu("show",1),slideUp:cu("hide",1),slideToggle:cu("toggle",1),fadeIn:{opacity:"show"},fadeOut:{opacity:"hide"},fadeToggle:{opacity:"toggle"}},function(a,b){f.fn[a]=function(a,c,d){return this.animate(b,a,c,d)}}),f.extend({speed:function(a,b,c){var d=a&&typeof a=="object"?f.extend({},a):{complete:c||!c&&b||f.isFunction(a)&&a,duration:a,easing:c&&b||b&&!f.isFunction(b)&&b};d.duration=f.fx.off?0:typeof d.duration=="number"?d.duration:d.duration in f.fx.speeds?f.fx.speeds[d.duration]:f.fx.speeds._default;if(d.queue==null||d.queue===!0)d.queue="fx";d.old=d.complete,d.complete=function(a){f.isFunction(d.old)&&d.old.call(this),d.queue?f.dequeue(this,d.queue):a!==!1&&f._unmark(this)};return d},easing:{linear:function(a,b,c,d){return c+d*a},swing:function(a,b,c,d){return(-Math.cos(a*Math.PI)/2+.5)*d+c}},timers:[],fx:function(a,b,c){this.options=b,this.elem=a,this.prop=c,b.orig=b.orig||{}}}),f.fx.prototype={update:function(){this.options.step&&this.options.step.call(this.elem,this.now,this),(f.fx.step[this.prop]||f.fx.step._default)(this)},cur:function(){if(this.elem[this.prop]!=null&&(!this.elem.style||this.elem.style[this.prop]==null))return this.elem[this.prop];var a,b=f.css(this.elem,this.prop);return isNaN(a=parseFloat(b))?!b||b==="auto"?0:b:a},custom:function(a,c,d){function h(a){return e.step(a)}var e=this,g=f.fx;this.startTime=cr||cs(),this.end=c,this.now=this.start=a,this.pos=this.state=0,this.unit=d||this.unit||(f.cssNumber[this.prop]?"":"px"),h.queue=this.options.queue,h.elem=this.elem,h.saveState=function(){e.options.hide&&f._data(e.elem,"fxshow"+e.prop)===b&&f._data(e.elem,"fxshow"+e.prop,e.start)},h()&&f.timers.push(h)&&!cp&&(cp=setInterval(g.tick,g.interval))},show:function(){var a=f._data(this.elem,"fxshow"+this.prop);this.options.orig[this.prop]=a||f.style(this.elem,this.prop),this.options.show=!0,a!==b?this.custom(this.cur(),a):this.custom(this.prop==="width"||this.prop==="height"?1:0,this.cur()),f(this.elem).show()},hide:function(){this.options.orig[this.prop]=f._data(this.elem,"fxshow"+this.prop)||f.style(this.elem,this.prop),this.options.hide=!0,this.custom(this.cur(),0)},step:function(a){var b,c,d,e=cr||cs(),g=!0,h=this.elem,i=this.options;if(a||e>=i.duration+this.startTime){this.now=this.end,this.pos=this.state=1,this.update(),i.animatedProperties[this.prop]=!0;for(b in i.animatedProperties)i.animatedProperties[b]!==!0&&(g=!1);if(g){i.overflow!=null&&!f.support.shrinkWrapBlocks&&f.each(["","X","Y"],function(a,b){h.style["overflow"+b]=i.overflow[a]}),i.hide&&f(h).hide();if(i.hide||i.show)for(b in i.animatedProperties)f.style(h,b,i.orig[b]),f.removeData(h,"fxshow"+b,!0),f.removeData(h,"toggle"+b,!0);d=i.complete,d&&(i.complete=!1,d.call(h))}return!1}i.duration==Infinity?this.now=e:(c=e-this.startTime,this.state=c/i.duration,this.pos=f.easing[i.animatedProperties[this.prop]](this.state,c,0,1,i.duration),this.now=this.start+(this.end-this.start)*this.pos),this.update();return!0}},f.extend(f.fx,{tick:function(){var a,b=f.timers,c=0;for(;c<b.length;c++)a=b[c],!a()&&b[c]===a&&b.splice(c--,1);b.length||f.fx.stop()},interval:13,stop:function(){clearInterval(cp),cp=null},speeds:{slow:600,fast:200,_default:400},step:{opacity:function(a){f.style(a.elem,"opacity",a.now)},_default:function(a){a.elem.style&&a.elem.style[a.prop]!=null?a.elem.style[a.prop]=a.now+a.unit:a.elem[a.prop]=a.now}}}),f.each(["width","height"],function(a,b){f.fx.step[b]=function(a){f.style(a.elem,b,Math.max(0,a.now)+a.unit)}}),f.expr&&f.expr.filters&&(f.expr.filters.animated=function(a){return f.grep(f.timers,function(b){return a===b.elem}).length});var cw=/^t(?:able|d|h)$/i,cx=/^(?:body|html)$/i;"getBoundingClientRect"in c.documentElement?f.fn.offset=function(a){var b=this[0],c;if(a)return this.each(function(b){f.offset.setOffset(this,a,b)});if(!b||!b.ownerDocument)return null;if(b===b.ownerDocument.body)return f.offset.bodyOffset(b);try{c=b.getBoundingClientRect()}catch(d){}var e=b.ownerDocument,g=e.documentElement;if(!c||!f.contains(g,b))return c?{top:c.top,left:c.left}:{top:0,left:0};var h=e.body,i=cy(e),j=g.clientTop||h.clientTop||0,k=g.clientLeft||h.clientLeft||0,l=i.pageYOffset||f.support.boxModel&&g.scrollTop||h.scrollTop,m=i.pageXOffset||f.support.boxModel&&g.scrollLeft||h.scrollLeft,n=c.top+l-j,o=c.left+m-k;return{top:n,left:o}}:f.fn.offset=function(a){var b=this[0];if(a)return this.each(function(b){f.offset.setOffset(this,a,b)});if(!b||!b.ownerDocument)return null;if(b===b.ownerDocument.body)return f.offset.bodyOffset(b);var c,d=b.offsetParent,e=b,g=b.ownerDocument,h=g.documentElement,i=g.body,j=g.defaultView,k=j?j.getComputedStyle(b,null):b.currentStyle,l=b.offsetTop,m=b.offsetLeft;while((b=b.parentNode)&&b!==i&&b!==h){if(f.support.fixedPosition&&k.position==="fixed")break;c=j?j.getComputedStyle(b,null):b.currentStyle,l-=b.scrollTop,m-=b.scrollLeft,b===d&&(l+=b.offsetTop,m+=b.offsetLeft,f.support.doesNotAddBorder&&(!f.support.doesAddBorderForTableAndCells||!cw.test(b.nodeName))&&(l+=parseFloat(c.borderTopWidth)||0,m+=parseFloat(c.borderLeftWidth)||0),e=d,d=b.offsetParent),f.support.subtractsBorderForOverflowNotVisible&&c.overflow!=="visible"&&(l+=parseFloat(c.borderTopWidth)||0,m+=parseFloat(c.borderLeftWidth)||0),k=c}if(k.position==="relative"||k.position==="static")l+=i.offsetTop,m+=i.offsetLeft;f.support.fixedPosition&&k.position==="fixed"&&(l+=Math.max(h.scrollTop,i.scrollTop),m+=Math.max(h.scrollLeft,i.scrollLeft));return{top:l,left:m}},f.offset={bodyOffset:function(a){var b=a.offsetTop,c=a.offsetLeft;f.support.doesNotIncludeMarginInBodyOffset&&(b+=parseFloat(f.css(a,"marginTop"))||0,c+=parseFloat(f.css(a,"marginLeft"))||0);return{top:b,left:c}},setOffset:function(a,b,c){var d=f.css(a,"position");d==="static"&&(a.style.position="relative");var e=f(a),g=e.offset(),h=f.css(a,"top"),i=f.css(a,"left"),j=(d==="absolute"||d==="fixed")&&f.inArray("auto",[h,i])>-1,k={},l={},m,n;j?(l=e.position(),m=l.top,n=l.left):(m=parseFloat(h)||0,n=parseFloat(i)||0),f.isFunction(b)&&(b=b.call(a,c,g)),b.top!=null&&(k.top=b.top-g.top+m),b.left!=null&&(k.left=b.left-g.left+n),"using"in b?b.using.call(a,k):e.css(k)}},f.fn.extend({position:function(){if(!this[0])return null;var a=this[0],b=this.offsetParent(),c=this.offset(),d=cx.test(b[0].nodeName)?{top:0,left:0}:b.offset();c.top-=parseFloat(f.css(a,"marginTop"))||0,c.left-=parseFloat(f.css(a,"marginLeft"))||0,d.top+=parseFloat(f.css(b[0],"borderTopWidth"))||0,d.left+=parseFloat(f.css(b[0],"borderLeftWidth"))||0;return{top:c.top-d.top,left:c.left-d.left}},offsetParent:function(){return this.map(function(){var a=this.offsetParent||c.body;while(a&&!cx.test(a.nodeName)&&f.css(a,"position")==="static")a=a.offsetParent;return a})}}),f.each(["Left","Top"],function(a,c){var d="scroll"+c;f.fn[d]=function(c){var e,g;if(c===b){e=this[0];if(!e)return null;g=cy(e);return g?"pageXOffset"in g?g[a?"pageYOffset":"pageXOffset"]:f.support.boxModel&&g.document.documentElement[d]||g.document.body[d]:e[d]}return this.each(function(){g=cy(this),g?g.scrollTo(a?f(g).scrollLeft():c,a?c:f(g).scrollTop()):this[d]=c})}}),f.each(["Height","Width"],function(a,c){var d=c.toLowerCase();f.fn["inner"+c]=function(){var a=this[0];return a?a.style?parseFloat(f.css(a,d,"padding")):this[d]():null},f.fn["outer"+c]=function(a){var b=this[0];return b?b.style?parseFloat(f.css(b,d,a?"margin":"border")):this[d]():null},f.fn[d]=function(a){var e=this[0];if(!e)return a==null?null:this;if(f.isFunction(a))return this.each(function(b){var c=f(this);c[d](a.call(this,b,c[d]()))});if(f.isWindow(e)){var g=e.document.documentElement["client"+c],h=e.document.body;return e.document.compatMode==="CSS1Compat"&&g||h&&h["client"+c]||g}if(e.nodeType===9)return Math.max(e.documentElement["client"+c],e.body["scroll"+c],e.documentElement["scroll"+c],e.body["offset"+c],e.documentElement["offset"+c]);if(a===b){var i=f.css(e,d),j=parseFloat(i);return f.isNumeric(j)?j:i}return this.css(d,typeof a=="string"?a:a+"px")}}),a.jQuery=a.$=f,typeof define=="function"&&define.amd&&define.amd.jQuery&&define("jquery",[],function(){return f})})(window);
define("../lib/jquery", function(){});

/*!
 * mustache.js - Logic-less {{mustache}} templates with JavaScript
 * http://github.com/janl/mustache.js
 */
var Mustache = (typeof module !== "undefined" && module.exports) || {};

(function (exports) {

  exports.name = "mustache.js";
  exports.version = "0.5.0-dev";
  exports.tags = ["{{", "}}"];
  exports.parse = parse;
  exports.compile = compile;
  exports.render = render;
  exports.clearCache = clearCache;

  // This is here for backwards compatibility with 0.4.x.
  exports.to_html = function (template, view, partials, send) {
    var result = render(template, view, partials);

    if (typeof send === "function") {
      send(result);
    } else {
      return result;
    }
  };

  var _toString = Object.prototype.toString;
  var _isArray = Array.isArray;
  var _forEach = Array.prototype.forEach;
  var _trim = String.prototype.trim;

  var isArray;
  if (_isArray) {
    isArray = _isArray;
  } else {
    isArray = function (obj) {
      return _toString.call(obj) === "[object Array]";
    };
  }

  var forEach;
  if (_forEach) {
    forEach = function (obj, callback, scope) {
      return _forEach.call(obj, callback, scope);
    };
  } else {
    forEach = function (obj, callback, scope) {
      for (var i = 0, len = obj.length; i < len; ++i) {
        callback.call(scope, obj[i], i, obj);
      }
    };
  }

  var spaceRe = /^\s*$/;

  function isWhitespace(string) {
    return spaceRe.test(string);
  }

  var trim;
  if (_trim) {
    trim = function (string) {
      return string == null ? "" : _trim.call(string);
    };
  } else {
    var trimLeft, trimRight;

    if (isWhitespace("\xA0")) {
      trimLeft = /^\s+/;
      trimRight = /\s+$/;
    } else {
      // IE doesn't match non-breaking spaces with \s, thanks jQuery.
      trimLeft = /^[\s\xA0]+/;
      trimRight = /[\s\xA0]+$/;
    }

    trim = function (string) {
      return string == null ? "" :
        String(string).replace(trimLeft, "").replace(trimRight, "");
    };
  }

  var escapeMap = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': '&quot;',
    "'": '&#39;'
  };

  function escapeHTML(string) {
    return String(string).replace(/&(?!\w+;)|[<>"']/g, function (s) {
      return escapeMap[s] || s;
    });
  }

  /**
   * Adds the `template`, `line`, and `file` properties to the given error
   * object and alters the message to provide more useful debugging information.
   */
  function debug(e, template, line, file) {
    file = file || "<template>";

    var lines = template.split("\n"),
        start = Math.max(line - 3, 0),
        end = Math.min(lines.length, line + 3),
        context = lines.slice(start, end);

    var c;
    for (var i = 0, len = context.length; i < len; ++i) {
      c = i + start + 1;
      context[i] = (c === line ? " >> " : "    ") + context[i];
    }

    e.template = template;
    e.line = line;
    e.file = file;
    e.message = [file + ":" + line, context.join("\n"), "", e.message].join("\n");

    return e;
  }

  /**
   * Looks up the value of the given `name` in the given context `stack`.
   */
  function lookup(name, stack, defaultValue) {
    if (name === ".") {
      return stack[stack.length - 1];
    }

    var names = name.split(".");
    var lastIndex = names.length - 1;
    var target = names[lastIndex];

    var value, context, i = stack.length, j, localStack;
    while (i) {
      localStack = stack.slice(0);
      context = stack[--i];

      j = 0;
      while (j < lastIndex) {
        context = context[names[j++]];

        if (context == null) {
          break;
        }

        localStack.push(context);
      }

      if (context && typeof context === "object" && target in context) {
        value = context[target];
        break;
      }
    }

    // If the value is a function, call it in the current context.
    if (typeof value === "function") {
      value = value.call(localStack[localStack.length - 1]);
    }

    if (value == null)  {
      return defaultValue;
    }

    return value;
  }

  function renderSection(name, stack, callback, inverted) {
    var buffer = "";
    var value =  lookup(name, stack);

    if (inverted) {
      // From the spec: inverted sections may render text once based on the
      // inverse value of the key. That is, they will be rendered if the key
      // doesn't exist, is false, or is an empty list.
      if (value == null || value === false || (isArray(value) && value.length === 0)) {
        buffer += callback();
      }
    } else if (isArray(value)) {
      forEach(value, function (value) {
        stack.push(value);
        buffer += callback();
        stack.pop();
      });
    } else if (typeof value === "object") {
      stack.push(value);
      buffer += callback();
      stack.pop();
    } else if (typeof value === "function") {
      var scope = stack[stack.length - 1];
      var scopedRender = function (template) {
        return render(template, scope);
      };
      buffer += value.call(scope, callback(), scopedRender) || "";
    } else if (value) {
      buffer += callback();
    }

    return buffer;
  }

  /**
   * Parses the given `template` and returns the source of a function that,
   * with the proper arguments, will render the template. Recognized options
   * include the following:
   *
   *   - file     The name of the file the template comes from (displayed in
   *              error messages)
   *   - tags     An array of open and close tags the `template` uses. Defaults
   *              to the value of Mustache.tags
   *   - debug    Set `true` to log the body of the generated function to the
   *              console
   *   - space    Set `true` to preserve whitespace from lines that otherwise
   *              contain only a {{tag}}. Defaults to `false`
   */
  function parse(template, options) {
    options = options || {};

    var tags = options.tags || exports.tags,
        openTag = tags[0],
        closeTag = tags[tags.length - 1];

    var code = [
      'var buffer = "";', // output buffer
      "\nvar line = 1;", // keep track of source line number
      "\ntry {",
      '\nbuffer += "'
    ];

    var spaces = [],      // indices of whitespace in code on the current line
        hasTag = false,   // is there a {{tag}} on the current line?
        nonSpace = false; // is there a non-space char on the current line?

    // Strips all space characters from the code array for the current line
    // if there was a {{tag}} on it and otherwise only spaces.
    var stripSpace = function () {
      if (hasTag && !nonSpace && !options.space) {
        while (spaces.length) {
          code.splice(spaces.pop(), 1);
        }
      } else {
        spaces = [];
      }

      hasTag = false;
      nonSpace = false;
    };

    var sectionStack = [], updateLine, nextOpenTag, nextCloseTag;

    var setTags = function (source) {
      tags = trim(source).split(/\s+/);
      nextOpenTag = tags[0];
      nextCloseTag = tags[tags.length - 1];
    };

    var includePartial = function (source) {
      code.push(
        '";',
        updateLine,
        '\nvar partial = partials["' + trim(source) + '"];',
        '\nif (partial) {',
        '\n  buffer += render(partial,stack[stack.length - 1],partials);',
        '\n}',
        '\nbuffer += "'
      );
    };

    var openSection = function (source, inverted) {
      var name = trim(source);

      if (name === "") {
        throw debug(new Error("Section name may not be empty"), template, line, options.file);
      }

      sectionStack.push({name: name, inverted: inverted});

      code.push(
        '";',
        updateLine,
        '\nvar name = "' + name + '";',
        '\nvar callback = (function () {',
        '\n  return function () {',
        '\n    var buffer = "";',
        '\nbuffer += "'
      );
    };

    var openInvertedSection = function (source) {
      openSection(source, true);
    };

    var closeSection = function (source) {
      var name = trim(source);
      var openName = sectionStack.length != 0 && sectionStack[sectionStack.length - 1].name;

      if (!openName || name != openName) {
        throw debug(new Error('Section named "' + name + '" was never opened'), template, line, options.file);
      }

      var section = sectionStack.pop();

      code.push(
        '";',
        '\n    return buffer;',
        '\n  };',
        '\n})();'
      );

      if (section.inverted) {
        code.push("\nbuffer += renderSection(name,stack,callback,true);");
      } else {
        code.push("\nbuffer += renderSection(name,stack,callback);");
      }

      code.push('\nbuffer += "');
    };

    var sendPlain = function (source) {
      code.push(
        '";',
        updateLine,
        '\nbuffer += lookup("' + trim(source) + '",stack,"");',
        '\nbuffer += "'
      );
    };

    var sendEscaped = function (source) {
      code.push(
        '";',
        updateLine,
        '\nbuffer += escapeHTML(lookup("' + trim(source) + '",stack,""));',
        '\nbuffer += "'
      );
    };

    var line = 1, c, callback;
    for (var i = 0, len = template.length; i < len; ++i) {
      if (template.slice(i, i + openTag.length) === openTag) {
        i += openTag.length;
        c = template.substr(i, 1);
        updateLine = '\nline = ' + line + ';';
        nextOpenTag = openTag;
        nextCloseTag = closeTag;
        hasTag = true;

        switch (c) {
        case "!": // comment
          i++;
          callback = null;
          break;
        case "=": // change open/close tags, e.g. {{=<% %>=}}
          i++;
          closeTag = "=" + closeTag;
          callback = setTags;
          break;
        case ">": // include partial
          i++;
          callback = includePartial;
          break;
        case "#": // start section
          i++;
          callback = openSection;
          break;
        case "^": // start inverted section
          i++;
          callback = openInvertedSection;
          break;
        case "/": // end section
          i++;
          callback = closeSection;
          break;
        case "{": // plain variable
          closeTag = "}" + closeTag;
          // fall through
        case "&": // plain variable
          i++;
          nonSpace = true;
          callback = sendPlain;
          break;
        default: // escaped variable
          nonSpace = true;
          callback = sendEscaped;
        }

        var end = template.indexOf(closeTag, i);

        if (end === -1) {
          throw debug(new Error('Tag "' + openTag + '" was not closed properly'), template, line, options.file);
        }

        var source = template.substring(i, end);

        if (callback) {
          callback(source);
        }

        // Maintain line count for \n in source.
        var n = 0;
        while (~(n = source.indexOf("\n", n))) {
          line++;
          n++;
        }

        i = end + closeTag.length - 1;
        openTag = nextOpenTag;
        closeTag = nextCloseTag;
      } else {
        c = template.substr(i, 1);

        switch (c) {
        case '"':
        case "\\":
          nonSpace = true;
          code.push("\\" + c);
          break;
        case "\r":
          // Ignore carriage returns.
          break;
        case "\n":
          spaces.push(code.length);
          code.push("\\n");
          stripSpace(); // Check for whitespace on the current line.
          line++;
          break;
        default:
          if (isWhitespace(c)) {
            spaces.push(code.length);
          } else {
            nonSpace = true;
          }

          code.push(c);
        }
      }
    }

    if (sectionStack.length != 0) {
      throw debug(new Error('Section "' + sectionStack[sectionStack.length - 1].name + '" was not closed properly'), template, line, options.file);
    }

    // Clean up any whitespace from a closing {{tag}} that was at the end
    // of the template without a trailing \n.
    stripSpace();

    code.push(
      '";',
      "\nreturn buffer;",
      "\n} catch (e) { throw {error: e, line: line}; }"
    );

    // Ignore `buffer += "";` statements.
    var body = code.join("").replace(/buffer \+= "";\n/g, "");

    if (options.debug) {
      if (typeof console != "undefined" && console.log) {
        console.log(body);
      } else if (typeof print === "function") {
        print(body);
      }
    }

    return body;
  }

  /**
   * Used by `compile` to generate a reusable function for the given `template`.
   */
  function _compile(template, options) {
    var args = "view,partials,stack,lookup,escapeHTML,renderSection,render";
    var body = parse(template, options);
    var fn = new Function(args, body);

    // This anonymous function wraps the generated function so we can do
    // argument coercion, setup some variables, and handle any errors
    // encountered while executing it.
    return function (view, partials) {
      partials = partials || {};

      var stack = [view]; // context stack

      try {
        return fn(view, partials, stack, lookup, escapeHTML, renderSection, render);
      } catch (e) {
        throw debug(e.error, template, e.line, options.file);
      }
    };
  }

  // Cache of pre-compiled templates.
  var _cache = {};

  /**
   * Clear the cache of compiled templates.
   */
  function clearCache() {
    _cache = {};
  }

  /**
   * Compiles the given `template` into a reusable function using the given
   * `options`. In addition to the options accepted by Mustache.parse,
   * recognized options include the following:
   *
   *   - cache    Set `false` to bypass any pre-compiled version of the given
   *              template. Otherwise, a given `template` string will be cached
   *              the first time it is parsed
   */
  function compile(template, options) {
    options = options || {};

    // Use a pre-compiled version from the cache if we have one.
    if (options.cache !== false) {
      if (!_cache[template]) {
        _cache[template] = _compile(template, options);
      }

      return _cache[template];
    }

    return _compile(template, options);
  }

  /**
   * High-level function that renders the given `template` using the given
   * `view` and `partials`. If you need to use any of the template options (see
   * `compile` above), you must compile in a separate step, and then call that
   * compiled function.
   */
  function render(template, view, partials) {
    return compile(template)(view, partials);
  }

})(Mustache);

define("../lib/mustache", function(){});


define('jquery.custom',["../lib/jquery", "../lib/mustache"], function() {
  var $;
  $ = jQuery;
  $.noConflict();
  $.fn.tagName = function() {
    return this[0].tagName.toLowerCase();
  };
  $.fn.getCoordinates = function() {
    var height, offset, width;
    offset = this.offset();
    width = this.width();
    height = this.height();
    return {
      top: offset.top,
      bottom: offset.top + height,
      left: offset.left,
      right: offset.left + width,
      width: width,
      height: height
    };
  };
  $.fn.getScroll = function() {
    return {
      x: this.scrollLeft(),
      y: this.scrollTop()
    };
  };
  $.fn.getSize = function() {
    return {
      x: this.width(),
      y: this.height()
    };
  };
  $.fn.isVisible = function() {
    var el;
    el = this.get(0);
    return !!(el.offsetHeight || el.offsetWidth);
  };
  $.fn.measure = function(fn) {
    var parent, res, restore, result, toMeasure, _i, _len;
    if (this.isVisible()) return fn.call(this);
    parent = this.parent();
    toMeasure = [];
    while (!parent.isVisible() && parent[0] !== document.body) {
      toMeasure.push(parent.expose());
      parent = parent.parent();
    }
    restore = this.expose();
    result = fn.call(this);
    restore();
    for (_i = 0, _len = toMeasure.length; _i < _len; _i++) {
      res = toMeasure[_i];
      res();
    }
    return result;
  };
  $.fn.expose = function() {
    var before, el,
      _this = this;
    if (this.css("display") !== 'none') return function() {};
    el = this[0];
    before = el.style.cssText;
    this.css({
      display: 'block',
      position: 'absolute',
      visibility: 'hidden'
    });
    return function() {
      return el.style.cssText = before;
    };
  };
  $.fn.isPartOfTable = function() {
    return $.inArray(this.tagName(), ["table", "colgroup", "col", "tbody", "thead", "tfoot", "tr", "th", "td"]) !== -1;
  };
  $.fn.isList = function() {
    return $.inArray(this.tagName(), ["ul", "ol"]) !== -1;
  };
  $.fn.merge = function(other) {
    var $a, $b, $other;
    $other = $(other);
    if (this.isPartOfTable() || $other.isPartOfTable()) return;
    $a = this.isList() ? this.find("li").last() : this;
    $b = $other.isList() ? $other.find("li").first() : $other;
    while ($b[0].childNodes[0]) {
      $a[0].appendChild($b[0].childNodes[0]);
    }
    $a[0].normalize();
    $b.remove();
    if ($other.isList() && $other.find("li").length === 0) return $other.remove();
  };
  $.fn.split = function(node) {
    var $first, $node;
    $node = $(node);
    $first = this.clone().html("").insertBefore(this);
    while (this[0].childNodes[0] && this[0].childNodes[0] !== node[0]) {
      $first.append(this[0].childNodes[0]);
    }
    return [$first, this];
  };
  $.fn.replaceElementWith = function(el) {
    var $el;
    $el = $(el).append(this[0].childNodes);
    return this.replaceWith($el);
  };
  $.fn.contexts = function(contexts, untilEl) {
    var $match, context, matchedContexts, _i, _len;
    if (untilEl == null) untilEl = null;
    matchedContexts = {};
    for (_i = 0, _len = contexts.length; _i < _len; _i++) {
      context = contexts[_i];
      $match = this.closest(context, untilEl);
      if ($match.length > 0) matchedContexts[context] = $match[0];
    }
    return matchedContexts;
  };
  $.mustache = function(template, view, partials) {
    return Mustache.render(template, view, partials);
  };
  $.fn.mustache = function(view, partials) {
    var output, template;
    template = $.trim($(this).html());
    return output = $.mustache(template, view, partials);
  };
  return $;
});


define('core/browser',["jquery.custom"], function($) {
  var Browser, hasW3CRanges, isGecko, isGecko1, isIE, isIE7, isIE8, isIE9, isWebkit;
  isIE = $.browser.msie;
  isIE7 = isIE && parseInt($.browser.version, 10) === 7;
  isIE8 = isIE && parseInt($.browser.version, 10) === 8;
  isIE9 = isIE && parseInt($.browser.version, 10) === 9;
  isGecko = $.browser.mozilla;
  isGecko1 = isGecko && parseInt($.browser.version, 10) === 1;
  isWebkit = $.browser.webkit;
  hasW3CRanges = !!window.getSelection;
  return Browser = {
    isIE: isIE,
    isIE7: isIE7,
    isIE8: isIE8,
    isIE9: isIE9,
    isGecko: isGecko,
    isGecko1: isGecko1,
    isWebkit: isWebkit,
    hasW3CRanges: hasW3CRanges
  };
});

var __hasProp = Object.prototype.hasOwnProperty;

define('core/helpers/helpers.keyboard',[], function() {
  return {
    keys: {
      enter: 13,
      up: 38,
      down: 40,
      left: 37,
      right: 39,
      esc: 27,
      space: 32,
      backspace: 8,
      tab: 9,
      "delete": 46
    },
    keyOf: function(event) {
      var fKey, k, key, v, _ref;
      if (event.type === 'keydown') {
        fKey = event.which - 111;
        if ((0 < fKey && fKey < 13)) key = 'f' + fKey;
      }
      if (!key) {
        _ref = this.keys;
        for (k in _ref) {
          if (!__hasProp.call(_ref, k)) continue;
          v = _ref[k];
          if (v === event.which) key = k;
        }
        if (!key) key = String.fromCharCode(event.which).toLowerCase();
      }
      return key;
    },
    keysOf: function(event) {
      var key, specialKeys;
      key = this.keyOf(event);
      specialKeys = [];
      if (event.altKey) specialKeys.push('alt');
      if (event.ctrlKey) specialKeys.push('ctrl');
      if (event.shiftKey) specialKeys.push('shift');
      return this.buildKey(key, specialKeys);
    },
    normalizeKeys: function(key) {
      var char, keys;
      keys = key.split('.');
      char = keys.pop();
      return this.buildKey(char, keys);
    },
    buildKey: function(key, specialKeys, delim) {
      var keys;
      if (specialKeys == null) specialKeys = [];
      if (delim == null) delim = '.';
      keys = specialKeys.sort();
      keys.push(key);
      return keys.join(delim);
    }
  };
});

var __slice = Array.prototype.slice;

define('core/helpers',["jquery.custom", "core/browser", "core/helpers/helpers.keyboard"], function($, Browser, Keyboard) {
  var Helpers;
  Helpers = {
    zeroWidthNoBreakSpace: "&#65279;",
    zeroWidthNoBreakSpaceUnicode: "\ufeff",
    nodeType: {
      ELEMENT: 1,
      TEXT: 3
    },
    isElement: function(object) {
      return object.nodeName && object.nodeType === this.nodeType.ELEMENT;
    },
    isTextnode: function(object) {
      return object.nodeName && object.nodeType === this.nodeType.TEXT;
    },
    isBlock: function(object, inDOM) {
      var $container, $object, isBlock;
      if (inDOM == null) inDOM = true;
      if (!this.isElement(object)) return false;
      $object = $(object);
      if (!inDOM) {
        $container = $("<div/>").hide().appendTo("body");
        $object.appendTo($container);
      }
      isBlock = $object.css("display") !== "inline";
      if (!inDOM) {
        $object.detach();
        $container.remove();
      }
      return isBlock;
    },
    nodesFrom: function(startNode, endNode) {
      var node, nodes;
      nodes = [];
      if (!(startNode && endNode)) return nodes;
      node = startNode;
      while (true) {
        nodes.push(node);
        if (node === endNode) break;
        node = node.nextSibling;
      }
      return nodes;
    },
    insertStyles: function(styles) {
      var style;
      if ($.trim(styles).length === 0) return;
      style = $('<style type="text/css" />')[0];
      if (Browser.isIE7 || Browser.isIE8) {
        style.styleSheet.cssText = styles;
      } else {
        style.innerHTML = styles;
      }
      return $(style).appendTo("head");
    },
    typeOf: function(object) {
      var type;
      type = $.type(object);
      if (type !== "object") return type;
      if (this.isElement(object)) return "element";
      if (this.isTextnode(object)) return "textnode";
      if ($.isWindow(object)) return "window";
      return type;
    },
    extend: function(klass, module) {
      return $.extend(klass, module);
    },
    include: function(klass, module) {
      var key, value, _results;
      _results = [];
      for (key in module) {
        value = module[key];
        _results.push(klass.prototype[key] = value);
      }
      return _results;
    },
    delegate: function() {
      var del, delFn, fn, fns, isDelFn, object, _i, _len, _results;
      object = arguments[0], del = arguments[1], fns = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      isDelFn = del.slice(-2) === "()";
      if (isDelFn) del = del.substring(0, del.length - 2);
      delFn = function(object, fn) {
        return object[fn] = function() {
          var delObject;
          delObject = object[del];
          if (isDelFn) delObject = delObject.apply(object);
          return delObject[fn].apply(delObject, arguments);
        };
      };
      _results = [];
      for (_i = 0, _len = fns.length; _i < _len; _i++) {
        fn = fns[_i];
        if (typeof object[fn] !== "undefined") {
          throw "Delegate: " + fn + " is already defined on " + object;
        }
        if (typeof object[del] === "undefined") {
          throw "Delegate: " + del + " does not exist on " + object;
        }
        _results.push(delFn(object, fn));
      }
      return _results;
    },
    pass: function(fn, args, bind) {
      return function() {
        return fn.apply(bind, $.makeArray(args));
      };
    },
    capitalize: function(string) {
      return string.replace(/\b[a-z]/g, function(match) {
        return match.toUpperCase();
      });
    }
  };
  $.extend(Helpers, Keyboard);
  return Helpers;
});


define('core/api/api.assets',[], function() {
  var Assets;
  return Assets = (function() {

    function Assets(path) {
      this.path = path != null ? path : "/";
      if (this.path[this.path.length - 1] !== "/") this.path += "/";
    }

    Assets.prototype.file = function(filename) {
      return this.path + filename;
    };

    Assets.prototype.image = function(filename) {
      return this.path + ("images/" + filename);
    };

    Assets.prototype.stylesheet = function(filename) {
      return this.path + ("stylesheets/" + filename);
    };

    Assets.prototype.template = function(filename) {
      return this.path + ("templates/" + filename);
    };

    return Assets;

  })();
});


define('core/events',["jquery.custom"], function($) {
  return {
    get$eventEl: function() {
      return this.$eventEl || (this.$eventEl = $("<div/>"));
    },
    on: function() {
      var _ref;
      return (_ref = this.get$eventEl()).on.apply(_ref, arguments);
    },
    off: function() {
      var _ref;
      return (_ref = this.get$eventEl()).off.apply(_ref, arguments);
    },
    trigger: function() {
      var _ref;
      return (_ref = this.get$eventEl()).trigger.apply(_ref, arguments);
    }
  };
});


define('core/range/range.w3c',["jquery.custom", "core/helpers"], function($, Helpers) {
  return {
    static: {
      getBlankRange: function() {
        return document.createRange();
      },
      getRangeFromSelection: function() {
        return window.getSelection().getRangeAt(0).cloneRange();
      },
      getRangeFromElement: function(el) {
        var range;
        range = this.getBlankRange();
        range.selectNode(el);
        return range;
      }
    },
    instance: {
      cloneRange: function() {
        return this.range.cloneRange();
      },
      isCollapsed: function() {
        return this.range.collapsed;
      },
      isImageSelected: function() {
        var div;
        div = $("<div/>").append(this.range.cloneContents())[0];
        return div.childNodes.length === 1 && div.childNodes[0].tagName.toLowerCase(0) === "img";
      },
      isStartOfElement: function(el) {
        var range, startText;
        range = this.cloneRange();
        range.setStartBefore(el);
        startText = $("<div/>").html(range.cloneContents()).text();
        return startText.match(/^[\n\t ]*$/);
      },
      isEndOfElement: function(el) {
        var endText, range;
        range = this.cloneRange();
        range.setEndAfter(el);
        endText = $("<div/>").html(range.cloneContents()).text();
        return endText.match(/^[\n\t ]*$/);
      },
      getImmediateParentElement: function() {
        var node;
        node = this.range.commonAncestorContainer;
        while (!Helpers.isElement(node)) {
          node = node.parentNode;
        }
        return node;
      },
      select: function(range) {
        var sel;
        range || (range = this.range);
        sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(range);
        this.range = range;
        return this;
      },
      unselect: function() {
        return window.getSelection().removeAllRanges();
      },
      selectEndOfElement: function(el) {
        this.range.selectNodeContents(el);
        this.range.collapse(false);
        this.select();
        return this.el.focus();
      },
      selectAfterElement: function(el) {
        this.range.selectNode(el);
        this.range.collapse(false);
        return this.select();
      },
      keepRange: function(fn) {
        var $end, $start, end, start;
        $start = $('<span id="RANGE_START"></span>');
        $end = $('<span id="RANGE_END"></span>');
        end = this.cloneRange();
        end.collapse(false);
        end.insertNode($end[0]);
        start = this.cloneRange();
        start.collapse(true);
        start.insertNode($start[0]);
        fn($start[0], $end[0]);
        $start = $("#RANGE_START");
        $end = $("#RANGE_END");
        this.range.setStart($start[0], 0);
        this.range.setEnd($end[0], 0);
        $start.remove();
        $end.remove();
        return this.select();
      },
      pasteNode: function(node) {
        this.range.insertNode(node);
        return this.selectAfterElement(node);
      },
      pasteHTML: function(html) {
        var div, last, node;
        this.select();
        div = document.createElement("div");
        div.innerHTML = html;
        last = div.lastChild;
        while (div.childNodes.length > 0 && (node = div.childNodes[div.childNodes.length - 1])) {
          this.range.insertNode(node);
        }
        return this.selectAfterElement(last);
      },
      surroundContents: function(el) {
        this.range.surroundContents(el);
        return this.selectAfterElement(el);
      },
      "delete": function() {
        var deleted, endElement, startElement, _ref,
          _this = this;
        this.select();
        _ref = this.getParentElements(function(el) {
          return Helpers.isBlock(el);
        }), startElement = _ref[0], endElement = _ref[1];
        deleted = $(startElement).closest("td, th", this.el)[0] === $(endElement).closest("td, th", this.el)[0];
        if (deleted) {
          this.keepRange(function(startEl, endEl) {
            _this.range.setStartAfter(startEl);
            _this.range.setEndBefore(endEl);
            _this.range.deleteContents();
            if (startElement !== endElement) {
              return $(startElement).merge(endElement);
            }
          });
        }
        return deleted;
      }
    }
  };
});


define('core/range/range.ie',["core/helpers"], function(Helpers) {
  return {
    static: {
      getBlankRange: function() {
        return document.body.createTextRange();
      },
      getRangeFromSelection: function() {
        return document.selection.createRange();
      },
      getRangeFromElement: function(el) {
        var range;
        if (el.nodeName === 'IMG') {
          range = document.body.createControlRange();
          range.add(el);
        } else {
          range = document.body.createTextRange();
          range.moveToElementText(el);
        }
        return range;
      }
    },
    instance: {
      cloneRange: function() {
        return this.range.duplicate();
      },
      isCollapsed: function() {
        return this.range.text.length === 0;
      },
      isImageSelected: function() {
        return typeof this.range.parentElement === "undefined";
      },
      isStartOfElement: function(el) {
        var elRange, range, startText;
        elRange = this.constructor.getRangeFromElement(el);
        range = this.cloneRange();
        range.setEndPoint("StartToStart", elRange);
        startText = range.htmlText;
        return startText.match(/^[\n\t ]*$/);
      },
      isEndOfElement: function(el) {
        var elRange, endText, range;
        elRange = this.constructor.getRangeFromElement(el);
        range = this.cloneRange();
        range.setEndPoint("EndToEnd", elRange);
        endText = range.htmlText;
        return endText.match(/^[\n\t ]*$/);
      },
      getImmediateParentElement: function() {
        return (this.range.parentElement && this.range.parentElement()) || this.range.item(0);
      },
      select: function(range) {
        range || (range = this.range);
        range.select();
        this.range = range;
        return this;
      },
      unselect: function() {
        return document.selection.empty();
      },
      selectEndOfElement: function(el) {
        this.range.moveToElementText(el);
        this.range.moveStart("character", this.range.text.length);
        this.range.collapse(true);
        return this.select();
      },
      keepRange: function(fn) {
        var $end, $start, range;
        range = this.constructor.getBlankRange();
        range.setEndPoint("StartToStart", this.range);
        range.collapse(true);
        range.pasteHTML('<span id="RANGE_START"></span>');
        range.setEndPoint("StartToEnd", this.range);
        range.collapse(false);
        range.pasteHTML('<span id="RANGE_END"></span>');
        fn($("#RANGE_START")[0], $("#RANGE_END")[0]);
        $start = $("#RANGE_START");
        $end = $("#RANGE_END");
        range.moveToElementText($start[0]);
        this.range.setEndPoint("StartToStart", range);
        range.moveToElementText($end[0]);
        this.range.setEndPoint("EndToStart", range);
        $start.remove();
        $end.remove();
        return this.select();
      },
      pasteNode: function(node) {
        var div;
        div = document.createElement("div");
        div.appendChild(node);
        return this.pasteHTML(div.innerHTML);
      },
      pasteHTML: function(html) {
        this.select();
        return this.range.pasteHTML(html);
      },
      surroundContents: function(el) {
        el.innerHTML = this.range.htmlText;
        return this.pasteNode(el);
      },
      "delete": function() {
        var deleted, endElement, startElement, _ref;
        this.select();
        _ref = this.getParentElements(function(el) {
          return Helpers.isBlock(el);
        }), startElement = _ref[0], endElement = _ref[1];
        deleted = $(startElement).closest("td, th", this.el)[0] === $(endElement).closest("td, th", this.el)[0];
        if (deleted) this.range.execCommand("delete");
        return deleted;
      }
    }
  };
});


define('core/range/range.module',["core/browser", "core/range/range.w3c", "core/range/range.ie"], function(Browser, W3C, IE) {
  var Module;
  Module = Browser.hasW3CRanges ? W3C : IE;
  return Module;
});


define('core/range/range.coordinates.ie7',["jquery.custom"], function($) {
  return {
    getCoordinates: function() {
      var clientRect, coords, windowScroll;
      if (this.range.getBoundingClientRect) {
        clientRect = this.range.getBoundingClientRect();
        windowScroll = $(window).getScroll();
        coords = {
          top: clientRect.top + windowScroll.y,
          bottom: clientRect.bottom + windowScroll.y,
          left: clientRect.left + windowScroll.x,
          right: clientRect.right + windowScroll.x
        };
      } else {
        coords = $(this.range.item(0)).getCoordinates();
      }
      return coords;
    }
  };
});


define('core/range/range.coordinates.ie8',["jquery.custom"], function($) {
  return {
    getCoordinates: function() {
      var coords, endCoords, startCoords;
      if (this.range.getBoundingClientRect) {
        if (this.isCollapsed()) {
          coords = this.getEdgeCoordinates(true);
        } else {
          startCoords = this.getEdgeCoordinates(true);
          endCoords = this.getEdgeCoordinates(false);
          coords = {
            top: startCoords.top,
            bottom: endCoords.bottom
          };
        }
      } else {
        coords = $(this.range.item(0)).getCoordinates();
      }
      return coords;
    },
    getEdgeCoordinates: function(start) {
      var bookmark, coords, span;
      bookmark = this.range.getBookmark();
      this.range.collapse(start);
      this.range.pasteHTML('<span id="CURSORPOS"></span>');
      span = $('#CURSORPOS');
      coords = span.getCoordinates();
      span.remove();
      this.range.moveToBookmark(bookmark);
      return coords;
    }
  };
});


define('core/range/range.coordinates.ie9',["jquery.custom"], function($) {
  return {
    getCoordinates: function() {
      var clientRect, coords, windowScroll;
      if (this.isImageSelected()) {
        coords = $(this.range.startContainer.childNodes[this.range.startOffset]).getCoordinates();
      } else {
        clientRect = this.range.getBoundingClientRect();
        windowScroll = $(window).getScroll();
        coords = {
          top: clientRect.top + windowScroll.y,
          bottom: clientRect.bottom + windowScroll.y,
          left: clientRect.left + windowScroll.x,
          right: clientRect.right + windowScroll.x
        };
      }
      return coords;
    }
  };
});


define('core/range/range.coordinates.webkit',["jquery.custom"], function($) {
  return {
    getCoordinates: function() {
      var clientRect, coords, span, windowScroll;
      if (this.isCollapsed()) {
        this.paste($('<span id="CURSORPOS">&#65279</span>')[0]);
        span = $('#CURSORPOS');
        coords = span.getCoordinates();
        span.remove();
        this.select();
      } else {
        clientRect = this.range.getBoundingClientRect();
        windowScroll = $(window).getScroll();
        coords = {
          top: clientRect.top + windowScroll.y,
          bottom: clientRect.bottom + windowScroll.y,
          left: clientRect.left + windowScroll.x,
          right: clientRect.right + windowScroll.x
        };
      }
      return coords;
    }
  };
});


define('core/range/range.coordinates.gecko1',["jquery.custom"], function($) {
  return {
    getCoordinates: function() {
      var $span, backwards, coords, savedRange, selection;
      backwards = this.isMovingBackwards();
      savedRange = this.range.cloneRange();
      this.collapse(backwards);
      if (backwards) {
        this.select();
        document.execCommand('inserthtml', false, '<span id="CURSORPOS">&#65279</span>');
      } else {
        this.pasteNode($('<span id="CURSORPOS">&#65279</span>')[0]);
      }
      $span = $('#CURSORPOS');
      coords = $span.getCoordinates();
      $span.remove();
      this.select(savedRange);
      if (backwards) {
        selection = window.getSelection();
        selection.collapseToEnd();
        selection.extend(this.range.startContainer, this.range.endContainer);
      }
      return coords;
    },
    isMovingBackwards: function() {
      var selection;
      selection = window.getSelection();
      return selection.anchorNode !== this.range.startContainer || selection.anchorOffset !== this.range.startOffset;
    }
  };
});


define('core/range/range.coordinates.gecko',["jquery.custom"], function($) {
  return {
    getCoordinates: function() {
      var clientRect, coords, span, windowScroll;
      if (this.isCollapsed()) {
        this.pasteNode($('<span id="CURSORPOS">&#65279</span>')[0]);
        span = $('#CURSORPOS');
        coords = span.getCoordinates();
        span.remove();
      } else {
        clientRect = this.range.getBoundingClientRect();
        windowScroll = $(window).getScroll();
        coords = {
          top: clientRect.top + windowScroll.y,
          bottom: clientRect.bottom + windowScroll.y,
          left: clientRect.left + windowScroll.x,
          right: clientRect.right + windowScroll.x
        };
      }
      return coords;
    }
  };
});


define('core/range/range.coordinates',["core/browser", "core/range/range.coordinates.ie7", "core/range/range.coordinates.ie8", "core/range/range.coordinates.ie9", "core/range/range.coordinates.webkit", "core/range/range.coordinates.gecko1", "core/range/range.coordinates.gecko"], function(Browser, IE7Coordinates, IE8Coordinates, IE9Coordinates, WebkitCoordinates, Gecko1Coordinates, GeckoCoordinates) {
  var Coordinates;
  if (Browser.isIE7) {
    Coordinates = IE7Coordinates;
  } else if (Browser.isIE8) {
    Coordinates = IE8Coordinates;
  } else if (Browser.isIE9) {
    Coordinates = IE9Coordinates;
  } else if (Browser.isWebkit) {
    Coordinates = WebkitCoordinates;
  } else if (Browser.isGecko1) {
    Coordinates = Gecko1Coordinates;
  } else if (Browser.isGecko) {
    Coordinates = GeckoCoordinates;
  } else {
    throw "Your browser is not currently supported.";
  }
  return Coordinates;
});


define('core/range',["jquery.custom", "core/helpers", "core/range/range.module", "core/range/range.coordinates"], function($, Helpers, Module, Coordinates) {
  var Range;
  Range = (function() {

    Range.EDITOR_ESCAPE_ERROR = new Object();

    Range.getBlankRange = function() {
      throw "Range.getBlankRange() needs to be overridden with a browser specific implementation";
    };

    Range.getRangeFromSelection = function() {
      throw "Range.getRangeFromSelection() needs to be overridden with a browser specific implementation";
    };

    Range.getRangeFromElement = function(el) {
      throw "Range.getRangeFromElement() needs to be overridden with a browser specific implementation";
    };

    function Range(el, arg) {
      this.el = el;
      if (!this.el) throw "new Range() is missing argument el";
      if (!Helpers.isElement(this.el)) throw "new Range() el is not an element";
      switch (Helpers.typeOf(arg)) {
        case "window":
          this.range = Range.getRangeFromSelection();
          break;
        case "element":
          this.range = Range.getRangeFromElement(arg);
          break;
        default:
          this.range = arg || Range.getBlankRange();
      }
    }

    Range.prototype.clone = function() {
      return new this.constructor(this.el, this.cloneRange());
    };

    Range.prototype.isCollapsed = function() {
      throw "#isCollapsed() needs to be overridden with a browser specific implementation";
    };

    Range.prototype.isImageSelected = function() {
      throw "#isImageSelected() needs to be overridden with a browser specific implementation";
    };

    Range.prototype.isStartOfElement = function() {
      throw "#isStartOfElement() needs to be overridden with a browser specific implementation";
    };

    Range.prototype.isEndOfElement = function() {
      throw "#isEndOfElement() needs to be overridden with a browser specific implementation";
    };

    Range.prototype.getCoordinates = function() {
      throw "#getCoordinates() needs to be overridden with a browser specific implementation";
    };

    Range.prototype.getParentElement = function(match) {
      var el, matchFn;
      switch (Helpers.typeOf(match)) {
        case "function":
          matchFn = match;
          break;
        case "string":
          matchFn = function(el) {
            return $(el).filter(match).length > 0;
          };
          break;
        case "null":
          matchFn = function() {
            return true;
          };
          break;
        case "undefined":
          matchFn = function() {
            return true;
          };
          break;
        default:
          throw "invalid type for match";
      }
      el = this.getImmediateParentElement();
      if (!el) return null;
      try {
        while (true) {
          if (el === this.el || el === document.body) {
            el = null;
            break;
          } else if (matchFn(el)) {
            break;
          } else {
            el = el.parentNode;
          }
        }
      } catch (e) {
        if (e === Range.EDITOR_ESCAPE_ERROR) {
          el = null;
        } else {
          throw e;
        }
      }
      return el;
    };

    Range.prototype.getParentElements = function(match) {
      var endParentElement, endRange, startParentElement, startRange;
      startRange = this.clone();
      startRange.collapse(true);
      startParentElement = startRange.getParentElement(match);
      endRange = this.clone();
      endRange.collapse(false);
      endParentElement = endRange.getParentElement(match);
      return [startParentElement, endParentElement];
    };

    Range.prototype.collapse = function(start) {
      this.range.collapse(start);
      return this;
    };

    Range.prototype.select = function(range) {
      throw "#select() needs to be overridden with a browser specific implementation";
    };

    Range.prototype.unselect = function() {
      throw "#unselect() needs to be overridden with a browser specific implementation";
    };

    Range.prototype.selectEndOfElement = function(el) {
      throw "#selectEndOfElement() needs to be overridden with a browser specific implementation";
    };

    Range.prototype.keepRange = function(fn) {
      throw "#keepRange() needs to be overridden with a browser specific implementation";
    };

    Range.prototype.paste = function(arg) {
      switch (Helpers.typeOf(arg)) {
        case "string":
          return this.pasteHTML(arg);
        case "element":
          return this.pasteNode(arg);
        default:
          throw "Don't know how to paste this type of arg";
      }
    };

    Range.prototype.surroundContents = function(el) {
      throw "#surroundContents() needs to be overridden with a browser specific implementation";
    };

    Range.prototype["delete"] = function() {
      throw "#delete() needs to be overridden with a browser specific implementation";
    };

    return Range;

  })();
  Helpers.extend(Range, Module.static);
  Helpers.include(Range, Module.instance);
  Helpers.include(Range, Coordinates);
  return Range;
});


define('core/api',["jquery.custom", "core/api/api.assets", "core/helpers", "core/events", "core/range"], function($, Assets, Helpers, Events, Range) {
  var API;
  API = (function() {

    function API(editor) {
      this.editor = editor;
      this.el = this.editor.$el[0];
      this.assets = new Assets(this.editor.config.path);
      this.whitelist = this.editor.whitelist;
      Helpers.delegate(this, "editor", "contents", "activate", "deactivate", "update");
      Helpers.delegate(this, "range()", "isCollapsed", "isImageSelected", "isStartOfElement", "isEndOfElement", "getCoordinates", "getParentElement", "getParentElements", "collapse", "unselect", "keepRange", "paste", "surroundContents", "delete");
      Helpers.delegate(this, "blankRange()", "selectEndOfElement");
      Helpers.delegate(this, "whitelist", "allowed", "replacement", "next");
    }

    API.prototype.range = function(el) {
      return new Range(this.el, el || window);
    };

    API.prototype.blankRange = function() {
      return new Range(this.el);
    };

    API.prototype.select = function(el) {
      return this.range(el).select();
    };

    API.prototype.defaultBlock = function() {
      return this.whitelist.getDefaults()["*"].getElement();
    };

    API.prototype.clean = function() {
      return this.trigger("clean", arguments);
    };

    return API;

  })();
  Helpers.include(API, Events);
  return API;
});


define('core/ui/ui.button',["jquery.custom", "core/helpers"], function($, Helpers) {
  var Button;
  Button = (function() {

    function Button(templates, options) {
      this.options = options;
      this.$tbTemplate = $(templates.toolbar);
      this.$cmTemplate = $(templates.contextmenu);
      this.checkOptions();
      this.normalizeIcon();
    }

    Button.prototype.checkOptions = function() {
      var iconType;
      if (typeof this.options === "undefined") throw "Missing button UI options";
      if (typeof this.options.action === "undefined") {
        throw "Missing action for button UI";
      }
      if (typeof this.options.description === "undefined") {
        throw "Missing description for " + this.options.action + " button UI";
      }
      iconType = Helpers.typeOf(this.options.icon);
      if (iconType !== "undefined") {
        if (iconType !== "object") {
          throw "Icon must be an object for " + this.options.action + " button UI";
        }
        if (typeof this.options.icon.url === "undefined") {
          throw "Icon must have a url for " + this.options.action + " button UI";
        }
        if (typeof this.options.icon.width === "undefined") {
          throw "Icon must have a width for " + this.options.action + " button UI";
        }
        if (typeof this.options.icon.height === "undefined") {
          throw "Icon must have a height for " + this.options.action + " button UI";
        }
      }
    };

    Button.prototype.normalizeIcon = function() {
      var _base;
      if (this.options.icon) {
        (_base = this.options.icon).offset || (_base.offset = [0, 0]);
        if (Helpers.typeOf(this.options.icon.width) === "number") {
          this.options.icon.width = "" + this.options.icon.width + "px";
        }
        if (Helpers.typeOf(this.options.icon.height) === "number") {
          return this.options.icon.height = "" + this.options.icon.height + "px";
        }
      }
    };

    Button.prototype.generateClass = function(type, action) {
      return this["class"] || (this["class"] = ("snapeditor_" + type + "_" + (action.replace(/[^a-zA-Z0-9]+/g, ""))).toLowerCase());
    };

    Button.prototype.getTitle = function() {
      if (this.title) return this.title;
      this.title = this.options.description;
      if (this.options.shortcut) {
        return this.title += " (" + this.options.shortcut + ")";
      }
    };

    Button.prototype.htmlForToolbar = function() {
      return this.$tbTemplate.mustache({
        action: this.options.action,
        title: this.getTitle(),
        "class": this.generateClass("toolbar", this.options.action)
      });
    };

    Button.prototype.htmlForContextMenu = function() {
      return this.$cmTemplate.mustache({
        action: this.options.action,
        description: this.options.description,
        shortcut: this.options.shortcut,
        "class": this.generateClass("contextmenu", this.options.action)
      });
    };

    Button.prototype.cssForToolbar = function() {
      var classname;
      if (!this.options.icon) return "";
      classname = this.generateClass("toolbar", this.options.action);
      return "        ." + classname + " {          background-image: url(" + this.options.icon.url + ");          background-repeat: no-repeat;          background-position: " + this.options.icon.offset[0] + "px " + this.options.icon.offset[1] + "px;          width: " + this.options.icon.width + ";          height: " + this.options.icon.height + ";        }        ." + classname + " input {          background-color: #0066cc;          border: none;          width: 100%;          height: " + this.options.icon.height + ";          opacity: 0.0;          filter: alpha(opacity=0);        }        ." + classname + " input:hover {          opacity: 0.2;          filter: alpha(opacity=20);        }      ";
    };

    Button.prototype.cssForContextMenu = function() {
      var classname, css;
      classname = this.generateClass("contextmenu", this.options.action);
      css = "        ." + classname + " {          width: 100%;          height: 30px;        }        ." + classname + " button {          background-color: white;          border: none;          padding: 0px 0px 0px 5px;          width: 100%;          height: 30px;        }        ." + classname + " button:hover {          background-color: #f9ffd0;        }        ." + classname + " table {          border-collapse: collapse;          border-spacing: 0px;          border: none;          width: 100%;        }        ." + classname + " td {          border: none;          padding: 0px;          height: 30px;        }        ." + classname + " .snapeditor_contextmenu_description {          text-align: left;          padding-left: 5px;          width: 60%;        }        ." + classname + " .snapeditor_contextmenu_shortcut {          text-align: right;          font-size: 90%;          color: #505050;          padding-right: 5px;          width: 40%;        }      ";
      if (this.options.icon) {
        return css += "          ." + classname + " .snapeditor_contextmenu_icon {            width: " + this.options.icon.width + "          }          ." + classname + " .snapeditor_contextmenu_icon div {            background-image: url(" + this.options.icon.url + ");            background-repeat: no-repeat;            background-position: " + this.options.icon.offset[0] + "px " + this.options.icon.offset[1] + "px;            width: " + this.options.icon.width + ";            height: " + this.options.icon.height + ";          }        ";
      } else {
        return css += "          ." + classname + " .snapeditor_contextmenu_icon {            width: 0px;          }        ";
      }
    };

    return Button;

  })();
  return Button;
});


define('core/ui/ui.gap',["jquery.custom"], function($) {
  var Gap;
  Gap = (function() {

    function Gap(template) {
      this.$template = $(template);
    }

    Gap.prototype.htmlForToolbar = function() {
      return this.$template.html();
    };

    Gap.prototype.htmlForContextMenu = function() {
      throw "A gap cannot be used for a contextmenu";
    };

    Gap.prototype.cssForToolbar = function() {
      return "";
    };

    Gap.prototype.cssForContextMenu = function() {
      throw "A gap cannot be used for a contextmenu";
    };

    return Gap;

  })();
  return Gap;
});


define('core/ui/ui',["jquery.custom", "core/ui/ui.button", "core/ui/ui.gap"], function($, Button, Gap) {
  var UI;
  UI = (function() {

    function UI(templates) {
      this.$templates = $(templates);
      this.setupTemplates();
    }

    UI.prototype.setupTemplates = function() {
      this.$tbButtonTemplate = this.$templates.find("#snapeditor_toolbar_button_template");
      this.$tbSelectTemplate = this.$templates.find("#snapeditor_toolbar_select_template");
      this.$tbGapTemplate = this.$templates.find("#snapeditor_toolbar_gap_template");
      this.$cmButtonTemplate = this.$templates.find("#snapeditor_contextmenu_button_template");
      return this.checkTemplates();
    };

    UI.prototype.checkTemplates = function() {
      if (this.$tbButtonTemplate.length === 0) {
        throw "Missing template. Make sure there is an element with id snapeditor_toolbar_button_template.";
      }
      if (this.$tbGapTemplate.length === 0) {
        throw "Missing template. Make sure there is an element with id snapeditor_toolbar_gap_template.";
      }
      if (this.$cmButtonTemplate.length === 0) {
        throw "Missing template. Make sure there is an element with id snapeditor_contextmenu_button_template.";
      }
    };

    UI.prototype.button = function(options) {
      var templates;
      templates = {
        toolbar: this.$tbButtonTemplate,
        contextmenu: this.$cmButtonTemplate
      };
      return new Button(templates, options);
    };

    UI.prototype.gap = function() {
      return new Gap(this.$tbGapTemplate);
    };

    return UI;

  })();
  return UI;
});


define('core/plugins',["jquery.custom", "core/ui/ui"], function($, UI) {
  var Plugins;
  Plugins = (function() {

    function Plugins(api, templates, defaultPlugins, extraPlugins, defaultToolbarComponents, customToolbarComponents) {
      this.api = api;
      this.templates = templates;
      this.defaultPlugins = defaultPlugins;
      this.extraPlugins = extraPlugins;
      this.defaultToolbarComponents = defaultToolbarComponents;
      this.customToolbarComponents = customToolbarComponents;
    }

    Plugins.prototype.setup = function() {
      var plugin, _i, _j, _len, _len2, _ref, _ref2;
      this.toolbarComponents = {
        config: this.customToolbarComponents || this.defaultToolbarComponents,
        available: {
          "-": this.getUI().gap()
        }
      };
      this.contextMenuButtons = {};
      this.keyboardShortcuts = {};
      _ref = this.defaultPlugins;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        plugin = _ref[_i];
        this.registerPlugin(plugin, true);
      }
      if (this.extraPlugins) {
        _ref2 = this.extraPlugins;
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          plugin = _ref2[_j];
          this.registerPlugin(plugin, false);
        }
      }
      return this.normalizeKeyboardShortcuts();
    };

    Plugins.prototype.getUI = function() {
      return this.ui || (this.ui = new UI(this.templates));
    };

    Plugins.prototype.registerPlugin = function(plugin, isDefault) {
      plugin.register(this.api);
      if (plugin.getUI) this.addUIs(plugin, isDefault);
      if (plugin.getActions) this.addActions(plugin);
      if (plugin.getKeyboardShortcuts) return this.addKeyboard(plugin);
    };

    Plugins.prototype.addUIs = function(plugin, isDefault) {
      var addDefault, defaultComponent, key, ui, value, _results;
      ui = plugin.getUI(this.getUI());
      addDefault = !(isDefault || this.customToolbarComponents);
      defaultComponent = ui["toolbar:default"];
      if (!defaultComponent && addDefault) {
        throw "'toolbar:default' must be defined for plugin " + plugin;
      }
      delete ui["toolbar:default"];
      _results = [];
      for (key in ui) {
        value = ui[key];
        _results.push(this.addUI(key, value, addDefault ? defaultComponent : null));
      }
      return _results;
    };

    Plugins.prototype.addUI = function(key, component, defaultComponent) {
      var buttons, match;
      if (defaultComponent == null) defaultComponent = null;
      key = key.toLowerCase();
      match = key.match(/^context:(.*)/);
      if (match) {
        buttons = this.contextMenuButtons[match[1]] || [];
        return this.contextMenuButtons[match[1]] = buttons.concat($.makeArray(component));
      } else {
        this.toolbarComponents.available[key] = $.makeArray(component);
        if (defaultComponent) {
          if (this.toolbarComponents.config.length !== 0) {
            this.toolbarComponents.config.push("|");
          }
          return this.toolbarComponents.config = this.toolbarComponents.config.concat($.makeArray(defaultComponent));
        }
      }
    };

    Plugins.prototype.addActions = function(plugin) {
      var action, event, _ref, _results;
      _ref = plugin.getActions();
      _results = [];
      for (event in _ref) {
        action = _ref[event];
        _results.push(this.addAction(plugin, event, action));
      }
      return _results;
    };

    Plugins.prototype.addAction = function(plugin, event, action) {
      return this.api.on("" + event, function() {
        return action.apply(plugin, arguments);
      });
    };

    Plugins.prototype.addKeyboard = function(plugin) {
      return $.extend(this.keyboardShortcuts, plugin.getKeyboardShortcuts());
    };

    Plugins.prototype.normalizeKeyboardShortcuts = function() {
      var action, key, _ref, _results;
      _ref = this.keyboardShortcuts;
      _results = [];
      for (key in _ref) {
        action = _ref[key];
        _results.push(this.setKeyboardShortcut(key, action));
      }
      return _results;
    };

    Plugins.prototype.setKeyboardShortcut = function(key, action) {
      var _this = this;
      return this.keyboardShortcuts[key] = function() {
        return _this.api.trigger(action);
      };
    };

    Plugins.prototype.getToolbarComponents = function() {
      if (!this.toolbarComponents) this.setup();
      return this.toolbarComponents;
    };

    Plugins.prototype.getContextMenuButtons = function() {
      if (!this.contextMenuButtons) this.setup();
      return this.contextMenuButtons;
    };

    Plugins.prototype.getContexts = function() {
      var buttons, context, _ref;
      if (this.contexts) return this.contexts;
      this.contexts = [];
      _ref = this.getContextMenuButtons();
      for (context in _ref) {
        buttons = _ref[context];
        this.contexts.push(context);
      }
      return this.contexts;
    };

    Plugins.prototype.getKeyboardShortcuts = function() {
      if (!this.keyboardShortcuts) this.setup();
      return this.keyboardShortcuts;
    };

    return Plugins;

  })();
  return Plugins;
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty;

define('core/keyboard',["jquery.custom", "core/helpers"], function($, Helpers) {
  var Keyboard;
  Keyboard = (function() {

    function Keyboard(api, keyboardShortcuts, type) {
      this.api = api;
      this.type = type;
      this.onkeydown = __bind(this.onkeydown, this);
      this.deactivate = __bind(this.deactivate, this);
      this.activate = __bind(this.activate, this);
      this.$el = $(this.api.el);
      this.keys = {};
      this.add(keyboardShortcuts);
      this.api.on("activate.editor", this.activate);
      this.api.on("deactivate.editor", this.deactivate);
    }

    Keyboard.prototype.add = function() {
      var arglen, fn, key, _ref, _results;
      arglen = arguments.length;
      if (arglen === 1) {
        if (!$.isPlainObject(arguments[0])) throw "Expected a map object";
        _ref = arguments[0];
        _results = [];
        for (key in _ref) {
          if (!__hasProp.call(_ref, key)) continue;
          fn = _ref[key];
          _results.push(this.add(key, fn));
        }
        return _results;
      } else if (arglen === 2) {
        return this.keys[Helpers.normalizeKeys(arguments[0])] = arguments[1];
      } else {
        throw "Wrong number of arguments to Keyboard#add";
      }
    };

    Keyboard.prototype.remove = function() {
      var key, _i, _len, _ref, _results;
      if ($.isArray(arguments[0])) {
        _ref = arguments[0];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          key = _ref[_i];
          _results.push(this.remove(key));
        }
        return _results;
      } else {
        return delete this.keys[Helpers.normalizeKeys(arguments[0])];
      }
    };

    Keyboard.prototype.activate = function() {
      return this.$el.on(this.type, this.onkeydown);
    };

    Keyboard.prototype.deactivate = function() {
      return this.$el.off(this.type, this.onkeydown);
    };

    Keyboard.prototype.onkeydown = function(e) {
      var fn, key;
      key = Helpers.keysOf(e);
      fn = this.keys[key];
      if (fn) {
        e.preventDefault();
        return fn();
      }
    };

    return Keyboard;

  })();
  return Keyboard;
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define('core/contexts',["jquery.custom"], function($) {
  var Contexts;
  Contexts = (function() {

    function Contexts(api, contexts) {
      this.api = api;
      this.contexts = contexts;
      this.updateContexts = __bind(this.updateContexts, this);
      this.onmouseup = __bind(this.onmouseup, this);
      this.onkeyup = __bind(this.onkeyup, this);
      this.deactivate = __bind(this.deactivate, this);
      this.activate = __bind(this.activate, this);
      this.$el = $(this.api.el);
      this.currentContexts = {};
      this.api.on("activate.editor", this.activate);
      this.api.on("deactivate.editor", this.deactivate);
    }

    Contexts.prototype.activate = function() {
      this.$el.on("keyup", this.onkeyup);
      this.$el.on("mouseup", this.onmouseup);
      return this.updateContexts();
    };

    Contexts.prototype.deactivate = function() {
      this.$el.off("keyup", this.onkeyup);
      this.$el.off("mouseup", this.onmouseup);
      return this.api.trigger("update.contexts", {
        contexts: {},
        removed: this.contexts
      });
    };

    Contexts.prototype.onkeyup = function(e) {
      var _ref;
      if (e.which === 13 || (33 <= (_ref = e.which) && _ref <= 40)) {
        return this.updateContexts();
      }
    };

    Contexts.prototype.onmouseup = function(e) {
      return this.updateContexts();
    };

    Contexts.prototype.updateContexts = function() {
      var matchedContexts, removedContexts;
      matchedContexts = $(this.api.getParentElement()).contexts(this.contexts, this.api.el);
      removedContexts = this.getRemovedContexts(matchedContexts);
      this.currentContexts = matchedContexts;
      return this.api.trigger("update.contexts", {
        contexts: matchedContexts,
        removed: removedContexts
      });
    };

    Contexts.prototype.getRemovedContexts = function(matchedContexts) {
      var context, el, removedContexts, _ref;
      removedContexts = [];
      _ref = this.currentContexts;
      for (context in _ref) {
        el = _ref[context];
        if (!matchedContexts[context]) removedContexts.push(context);
      }
      return removedContexts;
    };

    return Contexts;

  })();
  return Contexts;
});


define('core/contextmenu/contextmenu.builder',["jquery.custom", "core/helpers"], function($, Helpers) {
  var ContextMenuBuilder;
  ContextMenuBuilder = (function() {

    function ContextMenuBuilder(template, buttons) {
      this.buttons = buttons;
      this.$template = $(template);
      this.contextHTML = {};
    }

    ContextMenuBuilder.prototype.build = function(contexts) {
      var $menu;
      $menu = $(this.$template.mustache({
        componentGroups: this.getComponents(contexts)
      }));
      $menu.find("[data-action]").each(function() {
        return $(this).attr("unselectable", "on");
      });
      return $menu;
    };

    ContextMenuBuilder.prototype.getComponents = function(contexts) {
      var context, groups, _i, _len;
      groups = [];
      for (_i = 0, _len = contexts.length; _i < _len; _i++) {
        context = contexts[_i];
        groups.push({
          html: this.generateHTMLForContext(context)
        });
      }
      groups[groups.length - 1].last = true;
      return groups;
    };

    ContextMenuBuilder.prototype.generateHTMLForContext = function(context) {
      var button, buttons, css, html, _i, _len;
      if (this.contextHTML[context]) return this.contextHTML[context];
      html = "";
      css = "";
      buttons = this.buttons[context];
      if (context === "default") buttons || (buttons = []);
      if (!buttons) {
        throw "Missing contextmenu buttons for context '" + context + "'";
      }
      for (_i = 0, _len = buttons.length; _i < _len; _i++) {
        button = buttons[_i];
        html += button.htmlForContextMenu();
        css += button.cssForContextMenu();
      }
      Helpers.insertStyles(css);
      return this.contextHTML[context] = html;
    };

    return ContextMenuBuilder;

  })();
  return ContextMenuBuilder;
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define('core/data_action_handler',["jquery.custom"], function($) {
  var DataActionHandler;
  DataActionHandler = (function() {

    function DataActionHandler(el, api) {
      this.api = api;
      this.change = __bind(this.change, this);
      this.click = __bind(this.click, this);
      this.setClick = __bind(this.setClick, this);
      this.$el = $(el);
      this.$el.children("select[data-action]").on("change", this.change);
      this.$el.on("mousedown", this.setClick);
      this.$el.on("mouseup", this.click);
      this.$el.on("keypress", this.change);
    }

    DataActionHandler.prototype.setClick = function(e) {
      return this.isClick = true;
    };

    DataActionHandler.prototype.click = function(e) {
      var $button, target;
      if (this.isClick) {
        target = e.target;
        $button = $(target).closest("[data-action]:not(select)");
        if ($button.length > 0) {
          e.preventDefault();
          e.stopPropagation();
          this.api.trigger("" + ($button.attr("data-action")), target);
        }
      }
      this.isClick = false;
      return true;
    };

    DataActionHandler.prototype.change = function(e) {
      var $target;
      $target = $(e.target);
      if ($target.attr("data-action")) {
        return this.api.trigger("" + ($target.attr("data-action")), $target.val());
      }
    };

    return DataActionHandler;

  })();
  return DataActionHandler;
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define('core/contextmenu/contextmenu',["jquery.custom", "core/contextmenu/contextmenu.builder", "core/data_action_handler"], function($, Builder, DataActionHandler) {
  var ContextMenu;
  ContextMenu = (function() {

    function ContextMenu(api, templates, config) {
      var button, context, _ref;
      this.api = api;
      this.config = config;
      this.tryHide = __bind(this.tryHide, this);
      this.hide = __bind(this.hide, this);
      this.show = __bind(this.show, this);
      this.deactivate = __bind(this.deactivate, this);
      this.activate = __bind(this.activate, this);
      this.$el = $(this.api.el);
      this.$templates = $(templates);
      this.setupTemplates();
      this.contexts = [];
      _ref = this.config;
      for (context in _ref) {
        button = _ref[context];
        this.contexts.push(context);
      }
      this.setupMenu();
      this.api.on("activate.editor", this.activate);
      this.api.on("deactivate.editor", this.deactivate);
    }

    ContextMenu.prototype.setupTemplates = function() {
      this.$template = this.$templates.find("#snapeditor_contextmenu_template");
      if (this.$template.length === 0) {
        throw "Missing template. Make sure there is an element with id snapeditor_contextmenu_template.";
      }
    };

    ContextMenu.prototype.setupMenu = function() {
      this.id = "snapeditor_contextmenu_" + (Math.floor(Math.random() * 99999));
      this.$menu = $("<div/>").attr("id", this.id).addClass("snapeditor_contextmenu_container").css({
        position: "absolute",
        zIndex: 300
      }).hide().appendTo("body");
      new DataActionHandler(this.$menu, this.api);
      return this.builder = new Builder(this.$template, this.config);
    };

    ContextMenu.prototype.activate = function() {
      return this.$el.on("contextmenu", this.show);
    };

    ContextMenu.prototype.deactivate = function() {
      this.$el.off("contextmenu", this.show);
      return this.hide();
    };

    ContextMenu.prototype.show = function(e) {
      this.buildMenu(e.target);
      if (this.$menu.children().length > 0) {
        e.preventDefault();
        this.$menu.css(this.getStyles(e.pageX, e.pageY)).show();
        $(document).on("click", this.tryHide);
        return $(document).on("keydown", this.hide);
      }
    };

    ContextMenu.prototype.hide = function() {
      if (this.$menu) this.$menu.hide();
      $(document).off("click", this.tryHide);
      return $(document).off("keydown", this.hide);
    };

    ContextMenu.prototype.tryHide = function(e) {
      var $target;
      $target = $(e.target);
      if (!($target.attr("id") === this.id || $target.parent("#" + this.id).length > 0)) {
        return this.hide();
      }
    };

    ContextMenu.prototype.buildMenu = function(target) {
      var $target, context, contexts, el, matchedContexts;
      $target = $(target);
      matchedContexts = $target.contexts(this.contexts, this.$el);
      contexts = ["default"];
      for (context in matchedContexts) {
        el = matchedContexts[context];
        contexts.push(context);
      }
      this.$menu.empty();
      return this.$menu.append(this.builder.build(contexts));
    };

    ContextMenu.prototype.getMenuCoords = function() {
      return this.$menu.measure(function() {
        return this.getCoordinates();
      });
    };

    ContextMenu.prototype.getStyles = function(x, y) {
      var menuCoords, menuHeight, menuWidth, styles, windowBottom, windowRight, windowScroll, windowSize;
      styles = {
        top: y,
        left: x
      };
      windowScroll = $(window).getScroll();
      windowSize = $(window).getSize();
      windowBottom = windowScroll.y + windowSize.y;
      windowRight = windowScroll.x + windowSize.x;
      menuCoords = this.getMenuCoords();
      menuHeight = menuCoords.height;
      menuWidth = menuCoords.width;
      if (styles.top + menuHeight > windowBottom) {
        styles.top = windowBottom - menuHeight;
      }
      if (styles.left + menuWidth > windowRight) {
        styles.left = windowRight - menuWidth;
      }
      return styles;
    };

    return ContextMenu;

  })();
  return ContextMenu;
});


define('core/whitelist/whitelist.object',["jquery.custom", "core/browser"], function($, Browser) {
  var WhitelistObject;
  WhitelistObject = (function() {

    function WhitelistObject(tag, id, classes, attrs, next) {
      var attr, _i, _len;
      this.tag = tag;
      this.id = id != null ? id : null;
      this.classes = classes != null ? classes : [];
      if (attrs == null) attrs = [];
      this.next = next;
      this.classes = this.classes.sort().join(" ");
      this.attrs = {};
      for (_i = 0, _len = attrs.length; _i < _len; _i++) {
        attr = attrs[_i];
        this.attrs[attr] = true;
      }
    }

    WhitelistObject.prototype.getElement = function(templateEl) {
      var $el, attr, value, _ref;
      $el = $("<" + this.tag + ">");
      if (this.classes.length > 0) $el.attr("class", this.classes);
      if (templateEl) {
        _ref = this.attrs;
        for (attr in _ref) {
          value = _ref[attr];
          $el.attr(attr, $(templateEl).attr(attr));
        }
      }
      return $el[0];
    };

    WhitelistObject.prototype.matches = function(el) {
      return this.tagMatches(el) && this.idMatches(el) && this.classesMatch(el) && this.attributesAllowed(el);
    };

    WhitelistObject.prototype.tagMatches = function(el) {
      return $(el).tagName() === this.tag;
    };

    WhitelistObject.prototype.idMatches = function(el) {
      var id;
      id = $(el).attr("id");
      return !this.id && typeof id === "undefined" || this.id === id;
    };

    WhitelistObject.prototype.classesMatch = function(el) {
      return ($(el).attr("class") || "").split(" ").sort().join(" ") === this.classes;
    };

    WhitelistObject.prototype.attributesAllowed = function(el) {
      var attr, _i, _len, _ref;
      _ref = el.attributes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attr = _ref[_i];
        if (attr.name === "id" || attr.name === "class" || (Browser.isIE7 && !attr.specified)) {
          continue;
        }
        if (!this.attrs[attr.name]) return false;
      }
      return true;
    };

    return WhitelistObject;

  })();
  return WhitelistObject;
});

var __slice = Array.prototype.slice;

define('core/whitelist/whitelist.generator',["jquery.custom", "core/whitelist/whitelist.object"], function($, WhitelistObject) {
  var Generator;
  Generator = (function() {

    function Generator(whitelist) {
      this.whitelist = whitelist;
    }

    Generator.prototype.getDefaults = function() {
      if (!this.defaults) this.generateWhitelists();
      return this.defaults;
    };

    Generator.prototype.getWhitelistByLabel = function() {
      if (!this.whitelistByLabel) this.generateWhitelists();
      return this.whitelistByLabel;
    };

    Generator.prototype.getWhitelistByTag = function() {
      if (!this.whitelistByTag) this.generateWhitelists();
      return this.whitelistByTag;
    };

    Generator.prototype.generateWhitelists = function() {
      var label, obj, value, _ref;
      this.all = [];
      this.defaults = {};
      this.whitelistByLabel = {};
      this.whitelistByTag = {};
      _ref = this.whitelist;
      for (label in _ref) {
        value = _ref[label];
        if (this.isLabel(label)) {
          obj = this.parse(value);
          this.all.push(obj);
          this.whitelistByLabel[label] = obj;
          if (!this.whitelistByTag[obj.tag]) this.whitelistByTag[obj.tag] = [];
          this.whitelistByTag[obj.tag].push(obj);
        } else {
          if (!this.isLabel(value)) {
            throw "Whitelist default '" + label + ": " + value + "' must reference a label";
          }
          this.defaults[label] = value;
        }
      }
      return this.normalize();
    };

    Generator.prototype.normalize = function() {
      var label, obj, value, _i, _len, _ref, _ref2, _results;
      _ref = this.defaults;
      for (label in _ref) {
        value = _ref[label];
        this.defaults[label] = this.whitelistByLabel[value];
      }
      _ref2 = this.all;
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        obj = _ref2[_i];
        if (typeof obj.next === "string") {
          _results.push(obj.next = this.whitelistByLabel[obj.next]);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Generator.prototype.isLabel = function(label) {
      return !!label.match(/^[A-Z]/);
    };

    Generator.prototype.parse = function(string) {
      var attrs, classes, element, id, next, s, tag, _ref, _ref2, _ref3, _ref4;
      _ref = (function() {
        var _i, _len, _ref, _results;
        _ref = string.split(">");
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          s = _ref[_i];
          _results.push($.trim(s));
        }
        return _results;
      })(), element = _ref[0], next = _ref[1];
      _ref2 = (function() {
        var _i, _len, _ref2, _results;
        _ref2 = element.split("[");
        _results = [];
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          s = _ref2[_i];
          _results.push($.trim(s));
        }
        return _results;
      })(), element = _ref2[0], attrs = _ref2[1];
      _ref3 = (function() {
        var _i, _len, _ref3, _results;
        _ref3 = element.split(".");
        _results = [];
        for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
          s = _ref3[_i];
          _results.push($.trim(s));
        }
        return _results;
      })(), element = _ref3[0], classes = 2 <= _ref3.length ? __slice.call(_ref3, 1) : [];
      _ref4 = (function() {
        var _i, _len, _ref4, _results;
        _ref4 = element.split("#");
        _results = [];
        for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
          s = _ref4[_i];
          _results.push($.trim(s));
        }
        return _results;
      })(), tag = _ref4[0], id = _ref4[1];
      if (attrs) {
        attrs = (function() {
          var _i, _len, _ref5, _results;
          _ref5 = attrs.slice(0, -1).split(",");
          _results = [];
          for (_i = 0, _len = _ref5.length; _i < _len; _i++) {
            s = _ref5[_i];
            _results.push($.trim(s));
          }
          return _results;
        })();
      }
      if (next && !this.isLabel(next)) next = this.parse(next);
      return new WhitelistObject(tag, id, classes, attrs, next);
    };

    return Generator;

  })();
  return Generator;
});


define('core/whitelist/whitelist',["jquery.custom", "core/helpers", "core/whitelist/whitelist.generator"], function($, Helpers, Generator) {
  var Whitelist;
  return Whitelist = (function() {

    function Whitelist(whitelist) {
      this.whitelist = whitelist;
      this.generator = new Generator(this.whitelist);
      Helpers.delegate(this, "generator", "getDefaults", "getWhitelistByLabel", "getWhitelistByTag");
    }

    Whitelist.prototype.allowed = function(el) {
      return !!this.match(el);
    };

    Whitelist.prototype.replacement = function(el) {
      var $el, replacement, tag;
      $el = $(el);
      tag = $el.tagName();
      replacement = this.getDefaults()[tag] || null;
      if (!replacement) replacement = this.getReplacementFromWhitelistByTag(tag);
      return replacement && replacement.getElement(el);
    };

    Whitelist.prototype.next = function(el) {
      var match, next;
      next = this.getDefaults()["*"];
      if (!next) throw "The whitelist is missing a '*' default";
      match = this.match(el);
      if (match && match.next) next = match.next;
      return next.getElement();
    };

    Whitelist.prototype.match = function(el) {
      var list, match, obj, _i, _len;
      match = null;
      list = this.getWhitelistByTag()[$(el).tagName()];
      if (list) {
        for (_i = 0, _len = list.length; _i < _len; _i++) {
          obj = list[_i];
          if (obj.matches(el)) {
            match = obj;
            break;
          }
        }
      }
      return match;
    };

    Whitelist.prototype.getReplacementFromWhitelistByTag = function(tag) {
      var list, obj, replacement, _i, _len;
      list = this.getWhitelistByTag()[tag];
      if (!list) return null;
      replacement = null;
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        obj = list[_i];
        if (!obj.id) {
          replacement = obj;
          break;
        }
      }
      return replacement;
    };

    return Whitelist;

  })();
});


define('core/editor',["jquery.custom", "core/helpers", "core/api", "core/plugins", "core/keyboard", "core/contexts", "core/contextmenu/contextmenu", "core/whitelist/whitelist"], function($, Helpers, API, Plugins, Keyboard, Contexts, ContextMenu, Whitelist) {
  var Editor;
  Editor = (function() {

    function Editor(el, defaults, config) {
      this.defaults = defaults;
      this.config = config != null ? config : {};
      this.$el = $(el);
      this.whitelist = new Whitelist(this.defaults.whitelist);
      this.api = new API(this);
      this.loadAssets();
      this.plugins = new Plugins(this.api, this.$templates, this.defaults.plugins, this.config.plugins, this.defaults.toolbar, this.config.toolbar);
      this.keyboard = new Keyboard(this.api, this.plugins.getKeyboardShortcuts(), "keydown");
      this.contexts = new Contexts(this.api, this.plugins.getContexts());
      this.contextmenu = new ContextMenu(this.api, this.$templates, this.plugins.getContextMenuButtons());
    }

    Editor.prototype.loadAssets = function() {
      this.loadTemplates();
      return this.loadCSS();
    };

    Editor.prototype.loadTemplates = function() {
      var _this = this;
      return $.ajax({
        url: this.api.assets.template("snapeditor.html"),
        async: false,
        success: function(html) {
          return _this.$templates = $("<div/>").html(html);
        }
      });
    };

    Editor.prototype.loadCSS = function() {
      return $.ajax({
        url: this.api.assets.stylesheet("snapeditor.css"),
        async: false,
        success: function(css) {
          return Helpers.insertStyles(css);
        }
      });
    };

    Editor.prototype.activate = function() {
      this.api.trigger("activate.editor");
      return this.api.trigger("ready.editor");
    };

    Editor.prototype.deactivate = function() {
      return this.api.trigger("deactivate.editor");
    };

    Editor.prototype.update = function() {
      return this.api.trigger("update.editor");
    };

    Editor.prototype.contents = function() {
      var regexp;
      this.api.clean(this.api.el.firstChild, this.api.el.lastChild);
      regexp = new RegExp(Helpers.zeroWidthNoBreakSpaceUnicode, "g");
      return this.$el.html().replace(regexp, "");
    };

    return Editor;

  })();
  return Editor;
});


define('plugins/activate/activate.others',["jquery.custom"], function($) {
  return {
    addActivateEvents: function() {
      var _this = this;
      $(this.api.el).one("mousedown", function() {
        return _this.onmousedown.apply(_this, arguments);
      });
      return $(this.api.el).one("mouseup", function() {
        return _this.onmouseup.apply(_this, arguments);
      });
    },
    onmousedown: function(e) {
      if (!this.isLink(e.target)) return this.click();
    },
    onmouseup: function(e) {
      var target;
      target = e.target;
      if (!this.isLink(target)) {
        if ($(target).tagName() === 'img') this.api.select(target);
        return this.activate();
      }
    }
  };
});


define('plugins/activate/activate.ie',["jquery.custom"], function($) {
  return {
    addActivateEvents: function() {
      var _this = this;
      return $(this.api.el).one("mouseup", function() {
        return _this.onmouseup.apply(_this, arguments);
      });
    },
    onmouseup: function(e) {
      var isImage, range, target;
      target = e.target;
      if (!this.isLink(target)) {
        isImage = $(target).tagName() === "img";
        if (!isImage) range = this.api.range();
        this.click();
        if (isImage) {
          this.api.select(target);
        } else {
          range.select();
        }
        return this.activate();
      }
    }
  };
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define('plugins/activate/activate',["jquery.custom", "core/browser", "core/helpers", "core/events", "plugins/activate/activate.others", "plugins/activate/activate.ie"], function($, Browser, Helpers, Events, Others, IE) {
  var Activate;
  Activate = (function() {

    function Activate() {
      this.deactivate = __bind(this.deactivate, this);
    }

    Activate.prototype.register = function(api) {
      this.api = api;
      return this.addActivateEvents();
    };

    Activate.prototype.addActivateEvents = function() {
      throw "#addActivateEvents() needs to be overridden with a browser specific implementation";
    };

    Activate.prototype.click = function() {
      return this.api.trigger("click.activate");
    };

    Activate.prototype.activate = function() {
      this.api.activate();
      return this.api.on("deactivate.editor", this.deactivate);
    };

    Activate.prototype.deactivate = function() {
      this.api.off("deactivate.editor", this.deactivate);
      return this.addActivateEvents();
    };

    Activate.prototype.isLink = function(el) {
      var $el;
      $el = $(el);
      return $el.tagName() === 'a' || $el.parent('a').length !== 0;
    };

    return Activate;

  })();
  Helpers.include(Activate, Browser.isIE ? IE : Others);
  return Activate;
});


define('plugins/editable/editable.others',[], function() {
  return {
    start: function() {
      this.api.el.contentEditable = true;
      return document.execCommand("enableObjectResizing", false, false);
    }
  };
});


define('plugins/editable/editable.ie',["core/range"], function(Range) {
  return {
    start: function() {
      this.api.el.contentEditable = true;
      return this.api.el.attachEvent("onresizestart", this.preventResize);
    },
    deactivateBrowser: function() {
      return this.api.el.detachEvent("onresizestart", this.preventResize);
    },
    preventResize: function(e) {
      return e.returnValue = false;
    }
  };
});


define('plugins/editable/editable',["jquery.custom", "core/browser", "core/helpers", "plugins/editable/editable.others", "plugins/editable/editable.ie"], function($, Browser, Helpers, Others, IE) {
  var Editable, Module;
  Editable = (function() {

    function Editable() {}

    Editable.prototype.register = function(api) {
      var _this = this;
      this.api = api;
      return this.api.on("click.activate", function() {
        return _this.start.apply(_this);
      });
    };

    Editable.prototype.start = function() {
      throw "Editable.start() needs to be overridden with a browser specific implementation";
    };

    Editable.prototype.deactivate = function() {
      this.el.contentEditable = false;
      this.el.blur();
      return this.deactivateBrowser();
    };

    Editable.prototype.deactivateBrowser = function() {};

    return Editable;

  })();
  Module = Browser.isIE ? IE : Others;
  Helpers.include(Editable, Module);
  return Editable;
});


define('plugins/cleaner/cleaner.flattener',["jquery.custom"], function($) {
  var Flattener;
  Flattener = (function() {

    function Flattener() {}

    Flattener.prototype.doNotReplace = ["ol", "ul", "li", "table", "tbody", "thead", "tfoot", "tr", "th", "td", "caption"];

    Flattener.prototype.flatten = function(node) {
      switch ($(node).tagName()) {
        case "li":
          return this.flattenListItem(node);
        case "td":
        case "th":
          return this.flattenTableCell(node);
        default:
          if ($.inArray($(node).tagName(), this.doNotReplace) === -1) {
            return this.replaceWithChildren(node);
          }
      }
    };

    Flattener.prototype.replaceWithChildren = function(node) {
      var parent;
      parent = node.parentNode;
      while (node.childNodes[0]) {
        parent.insertBefore(node.childNodes[0], node);
      }
      return parent.removeChild(node);
    };

    Flattener.prototype.flattenBlock = function(block, template) {
      var $block, $els, el, i, selector, _ref;
      $block = $(block);
      switch ($block.tagName()) {
        case "ol":
        case "ul":
          selector = "li";
          break;
        case "table":
          selector = "th, td";
          break;
        default:
          return this.replaceWithChildren(block);
      }
      $els = $block.find(selector);
      for (i = 0, _ref = $els.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        el = $els[i];
        while (el.childNodes[0]) {
          $block.before(el.childNodes[0]);
        }
        if (i !== $els.length - 1) $block.before($(template).clone());
      }
      return $block.remove();
    };

    Flattener.prototype.flattenListItem = function(node) {
      var $cells, $li, $template, cell, child, _i, _len;
      $template = $("<li/>");
      while (node.childNodes[0]) {
        child = node.childNodes[0];
        switch ($(child).tagName()) {
          case "ul":
          case "ol":
            $(child).insertBefore(node);
            break;
          case "table":
            $cells = $(child).find("th, td");
            for (_i = 0, _len = $cells.length; _i < _len; _i++) {
              cell = $cells[_i];
              $li = $template.clone();
              $li.html(cell.innerHTML);
              $li.insertBefore(node);
            }
            $(child).remove();
            break;
          default:
            $li = $template.clone();
            $li.html(child.innerHTML);
            $li.insertBefore(node);
            $(child).remove();
        }
      }
      return $(node).remove();
    };

    Flattener.prototype.flattenTableCell = function(node) {
      var $template, child, nextSibling, _results;
      $template = $("<br/>");
      child = node.childNodes[0];
      _results = [];
      while (child) {
        nextSibling = child.nextSibling;
        this.flattenBlock(child, $template);
        if (nextSibling) $template.clone().insertBefore(nextSibling);
        _results.push(child = nextSibling);
      }
      return _results;
    };

    return Flattener;

  })();
  return Flattener;
});


define('plugins/cleaner/cleaner.normalizer',["jquery.custom", "core/helpers", "plugins/cleaner/cleaner.flattener"], function($, Helpers, Flattener) {
  var Normalizer;
  Normalizer = (function() {

    Normalizer.prototype.doNotUseAsTemplate = ["ol", "ul", "li", "table", "tbody", "thead", "tfoot", "tr", "th", "td", "caption", "colgroup", "col"];

    function Normalizer(api) {
      this.api = api;
      this.flattener = new Flattener();
    }

    Normalizer.prototype.normalize = function(startNode, endNode) {
      var inlineNodes, newEndNode, newStartNode, nextNode, node, parentNode, prevNode;
      parentNode = startNode.parentNode;
      prevNode = startNode.previousSibling;
      nextNode = endNode.nextSibling;
      if (!this.normalizeNodes(startNode, endNode)) {
        inlineNodes = [];
        newStartNode = (prevNode && prevNode.nextSibling) || parentNode.firstChild;
        newEndNode = (nextNode && nextNode.previousSibling) || parentNode.lastChild;
        node = newStartNode;
        while (true) {
          inlineNodes.push(node);
          if (node === newEndNode) break;
          node = node.nextSibling;
        }
        return this.blockify(inlineNodes, nextNode);
      }
    };

    Normalizer.prototype.normalizeNodes = function(startNode, endNode) {
      var blockFound, firstChild, inlineNodes, innerBlockFound, isBlock, lastChild, nextSibling, node, replacement, stop;
      blockFound = false;
      if (startNode && endNode) {
        inlineNodes = [];
        node = startNode;
        while (true) {
          stop = node === endNode;
          nextSibling = node.nextSibling;
          replacement = this.checkWhitelist(node);
          if (replacement) node = replacement;
          isBlock = Helpers.isBlock(node);
          if (isBlock) {
            blockFound = true;
            this.blockify(inlineNodes, node);
            inlineNodes = [];
          }
          if (Helpers.isElement(node)) {
            innerBlockFound = this.normalizeNodes(node.firstChild, node.lastChild);
            if (isBlock && !innerBlockFound && !replacement && node.firstChild) {
              $(node).replaceElementWith(this.api.defaultBlock());
            } else if (innerBlockFound || !replacement) {
              firstChild = node.firstChild;
              lastChild = node.lastChild;
              this.flattener.flatten(node);
              if (!isBlock) {
                inlineNodes = inlineNodes.concat(Helpers.nodesFrom(firstChild, lastChild));
              }
            } else if (!isBlock) {
              inlineNodes.push(node);
            }
          } else {
            inlineNodes.push(node);
          }
          if (stop) break;
          node = nextSibling;
        }
        if (blockFound) this.blockify(inlineNodes, null);
      }
      return blockFound;
    };

    Normalizer.prototype.blockify = function(inlineNodes, refNode) {
      var $block, $parent;
      if (inlineNodes.length > 0) {
        $parent = $(inlineNodes[0].parentNode);
        if ($parent[0] === this.api.el || $.inArray($parent.tagName(), this.doNotUseAsTemplate) !== -1) {
          $block = $(this.api.defaultBlock());
        } else {
          $block = $("<" + ($parent.tagName()) + "/>");
          $block.attr("class", $parent.attr("class"));
        }
        $block.append(inlineNodes);
        if (!$block.html().match(/^\s*$/)) {
          return $parent[0].insertBefore($block[0], refNode);
        }
      }
    };

    Normalizer.prototype.checkWhitelist = function(node) {
      var replacement;
      if (!Helpers.isElement(node)) return node;
      if (this.api.allowed(node)) return node;
      if (this.blacklisted(node)) return null;
      replacement = this.api.replacement(node);
      if (replacement) $(node).replaceElementWith(replacement);
      return replacement;
    };

    Normalizer.prototype.blacklisted = function(node) {
      var $el, blacklisted;
      if (!Helpers.isElement(node)) return false;
      blacklisted = false;
      $el = $(node);
      switch ($el.tagName()) {
        case "br":
          blacklisted = $el.hasClass("Apple-interchange-newline");
          break;
        case "span":
          blacklisted = $el.hasClass("Apple-style-span") || $el.hasClass("Apple-tab-span");
      }
      return blacklisted;
    };

    return Normalizer;

  })();
  return Normalizer;
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __slice = Array.prototype.slice;

define('plugins/cleaner/cleaner',["jquery.custom", "core/helpers", "plugins/cleaner/cleaner.normalizer"], function($, Helpers, Normalizer) {
  var Cleaner;
  Cleaner = (function() {

    function Cleaner() {
      this.cleanup = __bind(this.cleanup, this);
    }

    Cleaner.prototype.register = function(api) {
      var _this = this;
      this.api = api;
      this.$el = $(this.api.el);
      this.normalizer = new Normalizer(this.api);
      this.api.on("activate.editor", function() {
        return _this.clean(_this.api.el.firstChild, _this.api.el.lastChild);
      });
      this.api.on("clean", function() {
        var args, e;
        e = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        return _this.clean.apply(_this, args);
      });
      return this.clean(this.api.el.firstChild, this.api.el.lastChild);
    };

    Cleaner.prototype.clean = function() {
      switch (arguments.length) {
        case 0:
          this.api.keepRange(this.cleanup);
          break;
        case 2:
          this.cleanup.apply(this, arguments);
          break;
        default:
          throw "Wrong number of arguments to Cleaner.clean(). Expecting nothing () or (startNode, endNode).";
      }
      return this.api.trigger("finished.cleaner");
    };

    Cleaner.prototype.cleanup = function(startNode, endNode) {
      var endTopNode, startTopNode;
      if (startNode && endNode) {
        startTopNode = this.expandTopNode(this.findTopNode(startNode), true);
        endTopNode = this.expandTopNode(this.findTopNode(endNode), false);
        return this.normalizer.normalize(startTopNode, endTopNode);
      }
    };

    Cleaner.prototype.findTopNode = function(node) {
      var parent, topNode;
      topNode = node;
      parent = topNode.parentNode;
      while (parent !== this.api.el) {
        topNode = parent;
        parent = topNode.parentNode;
      }
      return topNode;
    };

    Cleaner.prototype.expandTopNode = function(node, backwards) {
      var direction, sibling, topNode;
      if (Helpers.isBlock(node)) return node;
      direction = backwards ? "previousSibling" : "nextSibling";
      topNode = node;
      sibling = topNode[direction];
      while (sibling && !Helpers.isBlock(sibling)) {
        topNode = sibling;
        sibling = topNode[direction];
      }
      return topNode;
    };

    return Cleaner;

  })();
  return Cleaner;
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define('plugins/erase_handler/erase_handler',["jquery.custom", "core/helpers", "core/browser"], function($, Helpers, Browser) {
  var EraseHandler;
  EraseHandler = (function() {

    function EraseHandler() {
      this.onkeyup = __bind(this.onkeyup, this);
      this.onkeydown = __bind(this.onkeydown, this);
      this.deactivate = __bind(this.deactivate, this);
      this.activate = __bind(this.activate, this);
    }

    EraseHandler.prototype.register = function(api) {
      this.api = api;
      if (Browser.isWebkit) {
        this.api.on("activate.editor", this.activate);
        return this.api.on("deactivate.editor", this.deactivate);
      }
    };

    EraseHandler.prototype.activate = function() {
      $(this.api.el).on("keydown", this.onkeydown);
      return $(this.api.el).on("keyup", this.onkeyup);
    };

    EraseHandler.prototype.deactivate = function() {
      $(this.api.el).off("keydown", this.onkeydown);
      return $(this.api.el).off("keyup", this.onkeyup);
    };

    EraseHandler.prototype.onkeydown = function(e) {
      var key;
      key = Helpers.keyOf(e);
      if (key === 'delete' || key === 'backspace') {
        if (this.api.isCollapsed()) {
          return this.handleCursor(e);
        } else {
          return this.api["delete"]();
        }
      }
    };

    EraseHandler.prototype.onkeyup = function(e) {
      var key;
      key = Helpers.keyOf(e);
      if (key === 'delete' || key === 'backspace') return this.api.clean();
    };

    EraseHandler.prototype.handleCursor = function(e) {
      var aNode, bNode, key, parentEl, range;
      range = this.api.range();
      parentEl = range.getParentElement(function(el) {
        return Helpers.isBlock(el);
      });
      key = Helpers.keyOf(e);
      if (key === 'delete' && range.isEndOfElement(parentEl)) {
        aNode = parentEl;
        bNode = $(parentEl).next()[0];
      } else if (key === 'backspace' && range.isStartOfElement(parentEl)) {
        aNode = $(parentEl).prev()[0];
        bNode = parentEl;
      }
      if (aNode && bNode) {
        e.preventDefault();
        return this.api.keepRange(function() {
          return $(aNode).merge(bNode);
        });
      }
    };

    return EraseHandler;

  })();
  return EraseHandler;
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define('plugins/enter_handler/enter_handler',["jquery.custom", "core/helpers"], function($, Helpers) {
  var EnterHandler;
  EnterHandler = (function() {

    function EnterHandler() {
      this.onkeydown = __bind(this.onkeydown, this);
      this.deactivate = __bind(this.deactivate, this);
      this.activate = __bind(this.activate, this);
    }

    EnterHandler.prototype.register = function(api) {
      this.api = api;
      this.api.on("activate.editor", this.activate);
      return this.api.on("deactivate.editor", this.deactivate);
    };

    EnterHandler.prototype.activate = function() {
      return $(this.api.el).on("keydown", this.onkeydown);
    };

    EnterHandler.prototype.deactivate = function() {
      return $(this.api.el).off("keydown", this.onkeydown);
    };

    EnterHandler.prototype.onkeydown = function(e) {
      if (Helpers.keysOf(e) === "enter") {
        e.preventDefault();
        return this.handleEnterKey();
      }
    };

    EnterHandler.prototype.handleEnterKey = function() {
      var next, parent;
      if (this.api["delete"]()) {
        parent = this.api.getParentElement();
        next = this.api.next(parent);
        if ($(next).tagName() === "br") {
          this.handleBR(next);
        } else {
          this.handleBlock(parent, next);
        }
        return this.api.clean();
      }
    };

    EnterHandler.prototype.handleBR = function(next) {
      return this.api.paste("" + next.outerHTML + Helpers.zeroWidthNoBreakSpace);
    };

    EnterHandler.prototype.handleBlock = function(block, next) {
      var _this = this;
      if (this.api.isEndOfElement(block)) {
        $(next).insertAfter(block).html(Helpers.zeroWidthNoBreakSpace);
        return this.api.selectEndOfElement(next);
      } else {
        return this.api.keepRange(function(startEl, endEl) {
          var $span;
          $span = $('<span id="ENTER_HANDLER"/>').insertBefore(startEl);
          $(block).split($span);
          return $span.remove();
        });
      }
    };

    return EnterHandler;

  })();
  return EnterHandler;
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define('plugins/empty_handler/empty_handler',["jquery.custom", "core/helpers"], function($, Helpers) {
  var EmptyHandler;
  EmptyHandler = (function() {

    function EmptyHandler() {
      this.onCleanerFinished = __bind(this.onCleanerFinished, this);
      this.onkeyup = __bind(this.onkeyup, this);
      this.deactivate = __bind(this.deactivate, this);
      this.activate = __bind(this.activate, this);
    }

    EmptyHandler.prototype.register = function(api) {
      this.api = api;
      this.api.on("activate.editor", this.activate);
      this.api.on("deactivate.editor", this.deactivate);
      return this.api.on("finished.cleaner", this.onCleanerFinished);
    };

    EmptyHandler.prototype.activate = function() {
      return $(this.api.el).on("keyup", this.onkeyup);
    };

    EmptyHandler.prototype.deactivate = function() {
      return $(this.api.el).off("keyup", this.onkeyup);
    };

    EmptyHandler.prototype.onkeyup = function(e) {
      var key;
      key = Helpers.keyOf(e);
      if ((key === 'delete' || key === 'backspace') && this.isEmpty()) {
        return this.deleteAll();
      }
    };

    EmptyHandler.prototype.onCleanerFinished = function() {
      if (this.isEmpty()) return this.insertDefaultBlock();
    };

    EmptyHandler.prototype.isEmpty = function() {
      return $(this.api.el).text().replace(/[\n\r\t ]/g, "").length === 0;
    };

    EmptyHandler.prototype.deleteAll = function() {
      $(this.api.el).empty();
      return this.insertDefaultBlock();
    };

    EmptyHandler.prototype.insertDefaultBlock = function() {
      var block;
      block = $(this.api.defaultBlock()).html(Helpers.zeroWidthNoBreakSpace)[0];
      this.api.el.appendChild(block);
      return this.api.selectEndOfElement(block);
    };

    return EmptyHandler;

  })();
  return EmptyHandler;
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define('plugins/edit/edit',["core/helpers"], function(Helpers) {
  var Edit;
  Edit = (function() {

    function Edit() {
      this.onkeyup = __bind(this.onkeyup, this);
      this.onkeydown = __bind(this.onkeydown, this);
      this.deactivate = __bind(this.deactivate, this);
      this.activate = __bind(this.activate, this);
    }

    Edit.prototype.register = function(api) {
      this.api = api;
      this.$el = $(this.api.el);
      this.api.on("activate.editor", this.activate);
      return this.api.on("deactivate.editor", this.deactivate);
    };

    Edit.prototype.getUI = function(ui) {
      var copy, cut, paste;
      cut = ui.button({
        action: "cut",
        description: "Cut",
        shortcut: "Ctrl+X",
        icon: {
          url: this.api.assets.image("contextmenu.png"),
          width: 16,
          height: 16,
          offset: [0, 0]
        }
      });
      copy = ui.button({
        action: "copy",
        description: "Copy",
        shortcut: "Ctrl+C",
        icon: {
          url: this.api.assets.image("contextmenu.png"),
          width: 16,
          height: 16,
          offset: [-16, 0]
        }
      });
      paste = ui.button({
        action: "paste",
        description: "Paste",
        shortcut: "Ctrl+V",
        icon: {
          url: this.api.assets.image("contextmenu.png"),
          width: 16,
          height: 16,
          offset: [-32, 0]
        }
      });
      return {
        "context:default": [cut, copy, paste]
      };
    };

    Edit.prototype.getActions = function() {
      return {
        cut: function() {
          return alert("Please use CTRL+X (or Command if you're on a Mac)");
        },
        copy: function() {
          return alert("Please use CTRL+C (or Command if you're on a Mac)");
        },
        paste: function() {
          return alert("Please use CTRL+V (or Command if you're on a Mac)");
        }
      };
    };

    Edit.prototype.activate = function() {
      this.$el.on("keydown", this.onkeydown);
      return this.$el.on("keyup", this.onkeyup);
    };

    Edit.prototype.deactivate = function() {
      this.$el.off("keydown", this.onkeydown);
      return this.$el.off("keyup", this.onkeyup);
    };

    Edit.prototype.onkeydown = function(e) {
      var endParent, keys, startParent, _ref;
      keys = Helpers.keysOf(e);
      if (keys === "ctrl.v") {
        _ref = this.api.getParentElements(function(el) {
          return Helpers.isBlock(el);
        }), startParent = _ref[0], endParent = _ref[1];
        return this.pasteStartParent = startParent && startParent.previousSibling;
      }
    };

    Edit.prototype.onkeyup = function(e) {
      var keys;
      keys = Helpers.keysOf(e);
      switch (keys) {
        case "ctrl.v":
          return this.paste();
        case "ctrl.x":
          return this.cut();
      }
    };

    Edit.prototype.cut = function() {
      return this.api.clean();
    };

    Edit.prototype.paste = function() {
      var pasteEndParent, pasteStartParent;
      pasteStartParent = this.pasteStartParent || this.api.el.firstChild;
      pasteEndParent = this.api.getParentElement(function(el) {
        return Helpers.isBlock(el);
      }) || this.api.el.lastChild;
      this.api.clean(pasteStartParent, pasteEndParent);
      return this.pasteStartParent = null;
    };

    return Edit;

  })();
  return Edit;
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define('plugins/styler/styler.inline',["jquery.custom", "core/browser"], function($, Browser) {
  var InlineStyler;
  InlineStyler = (function() {

    function InlineStyler() {
      this.link = __bind(this.link, this);
      this.italic = __bind(this.italic, this);
      this.bold = __bind(this.bold, this);
    }

    InlineStyler.prototype.register = function(api) {
      this.api = api;
    };

    InlineStyler.prototype.getDefaultToolbar = function() {
      return "Inline";
    };

    InlineStyler.prototype.getUI = function(ui) {
      var bold, italic, link;
      bold = ui.button({
        action: "bold",
        description: "Bold",
        shortcut: "Ctrl+B",
        icon: {
          url: this.api.assets.image("toolbar.png"),
          width: 31,
          height: 24,
          offset: [0, -101]
        }
      });
      italic = ui.button({
        action: "italic",
        description: "Italic",
        shortcut: "Ctrl+I",
        icon: {
          url: this.api.assets.image("toolbar.png"),
          width: 30,
          height: 24,
          offset: [-31, -101]
        }
      });
      link = ui.button({
        action: "link",
        description: "Insert Link",
        shortcut: "Ctrl+K",
        icon: {
          url: this.api.assets.image("toolbar.png"),
          width: 31,
          height: 24,
          offset: [0, -77]
        }
      });
      return {
        "toolbar:default": "inline",
        inline: [bold, italic, link],
        bold: bold,
        italic: italic,
        link: link
      };
    };

    InlineStyler.prototype.getActions = function() {
      return {
        bold: this.bold,
        italic: this.italic,
        link: this.link
      };
    };

    InlineStyler.prototype.getKeyboardShortcuts = function() {
      return {
        "ctrl.b": "bold",
        "ctrl.i": "italic",
        "ctrl.k": "link"
      };
    };

    InlineStyler.prototype.bold = function() {
      return this.format("b");
    };

    InlineStyler.prototype.italic = function() {
      return this.format("i");
    };

    InlineStyler.prototype.format = function(tag) {
      if (Browser.isGecko) document.execCommand("styleWithCSS", false, false);
      switch (tag) {
        case "b":
          this.exec("bold");
          break;
        case "i":
          this.exec("italic");
          break;
        default:
          throw "The inline style for tag " + tag + " is unsupported";
      }
      return this.update();
    };

    InlineStyler.prototype.exec = function(command, value) {
      if (value == null) value = null;
      return document.execCommand(command, false, value);
    };

    InlineStyler.prototype.link = function() {
      var href, link, parentLink;
      href = prompt("Enter URL of link", "http://");
      if (href) {
        href = $.trim(href);
        parentLink = this.api.getParentElement("a");
        if (parentLink) {
          $(parentLink).attr("href", href);
        } else if (this.api.isCollapsed()) {
          link = $("<a href=\"" + href + "\">" + href + "</a>");
          this.api.paste(link[0]);
        } else {
          link = $("<a href=\"" + href + "\"></a>");
          this.api.surroundContents(link[0]);
        }
        return this.update();
      }
    };

    InlineStyler.prototype.update = function() {
      if (Browser.isMozilla) this.api.el.focus();
      this.api.clean();
      return this.api.update();
    };

    return InlineStyler;

  })();
  return InlineStyler;
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define('plugins/styler/styler.block',["jquery.custom", "core/browser", "core/helpers"], function($, Browser, Helpers) {
  var BlockStyler;
  BlockStyler = (function() {

    function BlockStyler() {
      this.outdent = __bind(this.outdent, this);
      this.indent = __bind(this.indent, this);
      this.orderedList = __bind(this.orderedList, this);
      this.unorderedList = __bind(this.unorderedList, this);
      this.formatBlock = __bind(this.formatBlock, this);
      this.h3 = __bind(this.h3, this);
      this.h2 = __bind(this.h2, this);
      this.h1 = __bind(this.h1, this);
      this.p = __bind(this.p, this);
    }

    BlockStyler.prototype.register = function(api) {
      this.api = api;
    };

    BlockStyler.prototype.getUI = function(ui) {
      var h1, h2, h3, indent, orderedList, outdent, p, unorderedList;
      p = ui.button({
        action: "p",
        description: "Paragraph",
        shortcut: "Ctrl+0",
        icon: {
          url: this.api.assets.image("toolbar.png"),
          width: 31,
          height: 24,
          offset: [0, -53]
        }
      });
      h1 = ui.button({
        action: "h1",
        description: "H1",
        shortcut: "Ctrl+1",
        icon: {
          url: this.api.assets.image("toolbar.png"),
          width: 30,
          height: 24,
          offset: [-31, -53]
        }
      });
      h2 = ui.button({
        action: "h2",
        description: "H2",
        shortcut: "Ctrl+2",
        icon: {
          url: this.api.assets.image("toolbar.png"),
          width: 30,
          height: 24,
          offset: [-61, -53]
        }
      });
      h3 = ui.button({
        action: "h3",
        description: "H3",
        shortcut: "Ctrl+3",
        icon: {
          url: this.api.assets.image("toolbar.png"),
          width: 30,
          height: 24,
          offset: [-91, -53]
        }
      });
      unorderedList = ui.button({
        action: "unorderedList",
        description: "Bullet List",
        shortcut: "Ctrl+Shift+8",
        icon: {
          url: this.api.assets.image("toolbar.png"),
          width: 31,
          height: 24,
          offset: [0, -125]
        }
      });
      orderedList = ui.button({
        action: "orderedList",
        description: "Numbered List",
        shortcut: "Ctrl+Shift+3",
        icon: {
          url: this.api.assets.image("toolbar.png"),
          width: 30,
          height: 24,
          offset: [-31, -125]
        }
      });
      indent = ui.button({
        action: "indent",
        description: "Indent",
        icon: {
          url: this.api.assets.image("toolbar.png"),
          width: 30,
          height: 24,
          offset: [-61, -125]
        }
      });
      outdent = ui.button({
        action: "outdent",
        description: "Outdent",
        icon: {
          url: this.api.assets.image("toolbar.png"),
          width: 30,
          height: 24,
          offset: [-91, -125]
        }
      });
      return {
        "toolbar:default": "block",
        block: [p, h1, h2, h3, unorderedList, orderedList, indent, outdent],
        p: p,
        h1: h1,
        h2: h2,
        h3: h3,
        unorderedList: unorderedList,
        orderedList: orderedList,
        indent: indent,
        outdent: outdent
      };
    };

    BlockStyler.prototype.getActions = function() {
      return {
        p: this.p,
        h1: this.h1,
        h2: this.h2,
        h3: this.h3,
        unorderedList: this.unorderedList,
        orderedList: this.orderedList,
        indent: this.indent,
        outdent: this.outdent
      };
    };

    BlockStyler.prototype.getKeyboardShortcuts = function() {
      return {
        "ctrl.0": "p",
        "ctrl.1": "h1",
        "ctrl.2": "h2",
        "ctrl.3": "h3",
        "ctrl.shift.8": "unorderedList",
        "ctrl.shift.3": "orderedList"
      };
    };

    BlockStyler.prototype.p = function() {
      if (this.allowFormatBlock()) {
        this.formatBlock('p');
        return this.update();
      }
    };

    BlockStyler.prototype.h1 = function() {
      if (this.allowFormatBlock()) {
        this.formatBlock('h1');
        return this.update();
      }
    };

    BlockStyler.prototype.h2 = function() {
      if (this.allowFormatBlock()) {
        this.formatBlock('h2');
        return this.update();
      }
    };

    BlockStyler.prototype.h3 = function() {
      if (this.allowFormatBlock()) {
        this.formatBlock('h3');
        return this.update();
      }
    };

    BlockStyler.prototype.formatBlock = function(tag) {
      this.exec("formatblock", "<" + tag + ">");
      return this.update();
    };

    BlockStyler.prototype.unorderedList = function() {
      if (this.allowList()) {
        this.exec("insertunorderedlist");
        return this.update();
      }
    };

    BlockStyler.prototype.orderedList = function() {
      if (this.allowList()) {
        this.exec("insertorderedlist");
        return this.update();
      }
    };

    BlockStyler.prototype.indent = function() {
      this.exec("indent");
      return this.update();
    };

    BlockStyler.prototype.outdent = function() {
      this.exec("outdent");
      return this.update();
    };

    BlockStyler.prototype.exec = function(cmd, value) {
      if (value == null) value = null;
      return document.execCommand(cmd, false, value);
    };

    BlockStyler.prototype.update = function() {
      if (Browser.isMozilla) this.api.el.focus();
      this.api.clean();
      return this.api.update();
    };

    BlockStyler.prototype.allowFormatBlock = function() {
      var allowed;
      allowed = !this.api.getParentElement("table, li");
      if (!allowed) {
        alert("Sorry. This action cannot be performed inside a table or list.");
      }
      return allowed;
    };

    BlockStyler.prototype.allowList = function() {
      var allowed;
      allowed = !this.api.getParentElement("table");
      if (!allowed) {
        alert("Sorry. This action cannot be performed inside a table.");
      }
      return allowed;
    };

    return BlockStyler;

  })();
  return BlockStyler;
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define('plugins/table/table',["jquery.custom", "core/browser", "core/helpers"], function($, Browser, Helpers) {
  var Table;
  Table = (function() {

    function Table(options) {
      if (options == null) options = {};
      this.deleteCol = __bind(this.deleteCol, this);
      this.addCol = __bind(this.addCol, this);
      this.deleteRow = __bind(this.deleteRow, this);
      this.addRow = __bind(this.addRow, this);
      this.deleteTable = __bind(this.deleteTable, this);
      this.insertTable = __bind(this.insertTable, this);
      this.options = {
        table: [2, 3]
      };
      $.extend(this.options, options);
    }

    Table.prototype.register = function(api) {
      this.api = api;
    };

    Table.prototype.getUI = function(ui) {
      var addColLeft, addColRight, addRowAbove, addRowBelow, deleteCol, deleteRow, deleteTable, insertTable;
      insertTable = ui.button({
        action: "insertTable",
        description: "Insert Table",
        shortcut: "Ctrl+Shift+T",
        icon: {
          url: this.api.assets.image("toolbar.png"),
          width: 30,
          height: 24,
          offset: [-61, -77]
        }
      });
      addRowAbove = ui.button({
        action: "addRowAbove",
        description: "Add Row Above",
        shortcut: "Ctrl+Shift+Enter",
        icon: {
          url: this.api.assets.image("contextmenu.png"),
          width: 16,
          height: 16,
          offset: [0, -16]
        }
      });
      addRowBelow = ui.button({
        action: "addRowBelow",
        description: "Add Row Below",
        shortcut: "Ctrl+Enter",
        icon: {
          url: this.api.assets.image("contextmenu.png"),
          width: 16,
          height: 16,
          offset: [-16, -16]
        }
      });
      deleteRow = ui.button({
        action: "deleteRow",
        description: "Delete Row",
        icon: {
          url: this.api.assets.image("contextmenu.png"),
          width: 16,
          height: 16,
          offset: [-32, -16]
        }
      });
      addColLeft = ui.button({
        action: "addColLeft",
        description: "Add Column Left",
        shortcut: "Ctrl+Shift+M",
        icon: {
          url: this.api.assets.image("contextmenu.png"),
          width: 16,
          height: 16,
          offset: [-48, -16]
        }
      });
      addColRight = ui.button({
        action: "addColRight",
        description: "Add Column Right",
        shortcut: "Ctrl+M",
        icon: {
          url: this.api.assets.image("contextmenu.png"),
          width: 16,
          height: 16,
          offset: [-64, -16]
        }
      });
      deleteCol = ui.button({
        action: "deleteCol",
        description: "Delete Column",
        icon: {
          url: this.api.assets.image("contextmenu.png"),
          width: 16,
          height: 16,
          offset: [-80, -16]
        }
      });
      deleteTable = ui.button({
        action: "deleteTable",
        description: "Delete Table",
        icon: {
          url: this.api.assets.image("contextmenu.png"),
          width: 16,
          height: 16,
          offset: [-96, -16]
        }
      });
      return {
        "toolbar:default": "table",
        table: insertTable,
        "context:table": [addRowAbove, addRowBelow, deleteRow, addColLeft, addColRight, deleteCol, deleteTable]
      };
    };

    Table.prototype.getActions = function() {
      var _this = this;
      return {
        insertTable: this.insertTable,
        deleteTable: function(e) {
          return _this.deleteTable();
        },
        addRowAbove: Helpers.pass(this.addRow, true, this),
        addRowBelow: Helpers.pass(this.addRow, false, this),
        deleteRow: this.deleteRow,
        addColLeft: Helpers.pass(this.addCol, true, this),
        addColRight: Helpers.pass(this.addCol, false, this),
        deleteCol: this.deleteCol
      };
    };

    Table.prototype.getKeyboardShortcuts = function() {
      return {
        "ctrl.shift.t": "table",
        "ctrl.shift.enter": "addRowAbove",
        "ctrl.enter": "addRowBelow",
        "ctrl.shift.m": "addColLeft",
        "ctrl.m": "addColRight"
      };
    };

    Table.prototype.insertTable = function() {
      var $table, $tbody, $td, $tr, i, _ref, _ref2;
      if (this.api.getParentElement("table, li")) {
        return alert("Sorry. This action cannot be performed inside a table or list.");
      } else {
        $table = $('<table id="INSERTED_TABLE"></table>');
        $tbody = $("<tbody/>").appendTo($table);
        $td = $("<td>&nbsp;</td>");
        $tr = $("<tr/>");
        for (i = 1, _ref = this.options.table[1]; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
          $tr.append($td.clone());
        }
        for (i = 1, _ref2 = this.options.table[0]; 1 <= _ref2 ? i <= _ref2 : i >= _ref2; 1 <= _ref2 ? i++ : i--) {
          $tbody.append($tr.clone());
        }
        this.api.paste($table[0]);
        $table = $("#INSERTED_TABLE");
        this.api.selectEndOfElement($table.find("td")[0]);
        $table.removeAttr("id");
        return this.update();
      }
    };

    Table.prototype.deleteTable = function(table) {
      var $p, $table;
      table = table || this.api.getParentElement("table");
      if (table) {
        $table = $(table);
        if (Browser.hasW3CRanges) {
          $p = $("<p>" + Helpers.zeroWidthNoBreakSpace + "</p>");
          $table.replaceWith($p);
          this.api.selectEndOfElement($p[0]);
        } else {
          $table.remove();
        }
        return this.update();
      }
    };

    Table.prototype.addRow = function(before) {
      var $cell, $newTr, $tds, $tr, cell, i, _ref;
      cell = this.getCell();
      if (cell) {
        $cell = $(cell);
        $tr = $cell.parent("tr");
        $tds = $tr.children();
        $newTr = $("<tr/>");
        for (i = 1, _ref = $tds.length; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
          $newTr.append($("<td>" + Helpers.zeroWidthNoBreakSpace + "</td>"));
        }
        $tr[before ? "before" : "after"]($newTr);
        this.api.selectEndOfElement($newTr.children("td")[0]);
        return this.update();
      }
    };

    Table.prototype.deleteRow = function() {
      var $defaultTr, $tr, tr;
      tr = this.api.getParentElement("tr");
      if (tr) {
        $tr = $(tr);
        $defaultTr = $tr.next("tr");
        if (!($defaultTr.length > 0)) $defaultTr = $tr.prev("tr");
        if ($defaultTr.length > 0) {
          this.api.selectEndOfElement($defaultTr.children()[0]);
          $tr.remove();
        } else {
          this.deleteTable($tr.closest("table", this.api.el)[0]);
        }
        return this.update();
      }
    };

    Table.prototype.addCol = function(before) {
      var $cell, $nextCell, cell;
      cell = this.getCell();
      if (cell) {
        $cell = $(cell);
        this.eachCellInCol($cell, function() {
          var newCell;
          newCell = $(this).clone(false).html(Helpers.zeroWidthNoBreakSpace);
          return $(this)[before ? "before" : "after"](newCell);
        });
        $nextCell = $cell[before ? "prev" : "next"]($cell.tagName());
        this.api.selectEndOfElement($nextCell[0]);
        return this.update();
      }
    };

    Table.prototype.deleteCol = function() {
      var $cell, $defaultCell, cell;
      cell = this.getCell();
      if (cell) {
        $cell = $(cell);
        $defaultCell = $cell.next();
        if (!($defaultCell.length > 0)) $defaultCell = $cell.prev();
        if ($defaultCell.length > 0) {
          this.api.selectEndOfElement($defaultCell[0]);
          this.eachCellInCol($cell, function() {
            return $(this).remove();
          });
        } else {
          this.deleteTable($cell.closest("table", this.api.el));
        }
        return this.update();
      }
    };

    Table.prototype.getCell = function() {
      return this.api.getParentElement(function(el) {
        var tag;
        tag = $(el).tagName();
        return tag === 'td' || tag === 'th';
      });
    };

    Table.prototype.eachCellInCol = function(cell, fn) {
      var $cell, $cells, $tr, i, row, _i, _len, _ref, _ref2, _results;
      $cell = $(cell);
      $tr = $cell.parent("tr");
      $cells = $tr.children();
      for (i = 0, _ref = $cells.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        if ($cells[i] === $cell[0]) break;
      }
      _ref2 = $tr.parent().children("tr");
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        row = _ref2[_i];
        _results.push(fn.apply($(row).children()[i]));
      }
      return _results;
    };

    Table.prototype.update = function() {
      if (Browser.isMozilla) this.api.el.focus();
      this.api.clean();
      return this.api.update();
    };

    return Table;

  })();
  return Table;
});


define('config/config.default',["plugins/activate/activate", "plugins/editable/editable", "plugins/cleaner/cleaner", "plugins/erase_handler/erase_handler", "plugins/enter_handler/enter_handler", "plugins/empty_handler/empty_handler", "plugins/edit/edit", "plugins/styler/styler.inline", "plugins/styler/styler.block", "plugins/table/table"], function(Activate, Editable, Cleaner, EraseHandler, EnterHandler, EmptyHandler, Edit, InlineStyler, BlockStyler, Table) {
  return {
    build: function() {
      return {
        plugins: [new Activate(), new Editable(), new Cleaner(), new EraseHandler(), new EnterHandler(), new EmptyHandler(), new Edit(), new InlineStyler(), new BlockStyler(), new Table()],
        toolbar: ["Bold", "Italic", "|", "P", "H1", "H2", "H3", "|", "UnorderedList", "OrderedList", "Indent", "Outdent", "|", "Link", "Table"],
        whitelist: {
          "Paragraph": "p > Paragraph",
          "Div": "div > Div",
          "Heading 1": "h1 > Paragraph",
          "Heading 2": "h2 > Paragraph",
          "Heading 3": "h3 > Paragraph",
          "Unordered List": "ul",
          "Ordered List": "ol",
          "List Item": "li > List Item",
          "Table": "table",
          "Table Body": "tbody",
          "Table Row": "tr",
          "Table Header": "th > BR",
          "Table Cell": "td > BR",
          "BR": "br",
          "Bold": "b",
          "Strong": "strong",
          "Italic": "i",
          "Emphasis": "em",
          "Links": "a[href]",
          "Range Start": "span#RANGE_START",
          "Range End": "span#RANGE_END",
          "*": "Paragraph"
        }
      };
    }
  };
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define('plugins/snap/snap',["jquery.custom"], function($) {
  var Snap;
  Snap = (function() {

    function Snap() {
      this.tryCancel = __bind(this.tryCancel, this);
      this.setCancel = __bind(this.setCancel, this);
      this.update = __bind(this.update, this);
      this.unsnap = __bind(this.unsnap, this);
      this.snap = __bind(this.snap, this);
    }

    Snap.prototype.register = function(api) {
      this.api = api;
      this.$el = $(this.api.el);
      this.api.on("activate.editor", this.snap);
      this.api.on("deactivate.editor", this.unsnap);
      return this.api.on("update.editor", this.update);
    };

    Snap.prototype.setup = function() {
      var div;
      div = $("<div/>").css({
        opacity: 0.2,
        position: 'absolute',
        background: 'black',
        top: 0,
        left: 0,
        zIndex: 100
      });
      div.on("mousedown", this.setCancel);
      div.on("mouseup", this.tryCancel);
      return this.divs = {
        top: div.clone(true, false).appendTo("body"),
        bottom: div.clone(true, false).appendTo("body"),
        left: div.clone(true, false).appendTo("body"),
        right: div.clone(true, false).appendTo("body")
      };
    };

    Snap.prototype.snap = function() {
      var div, options, position, _ref, _ref2, _ref3;
      if (!this.divs) this.setup();
      _ref = this.divs;
      for (position in _ref) {
        div = _ref[position];
        div.show();
      }
      options = this.getFxOptions();
      _ref2 = this.divs;
      for (position in _ref2) {
        div = _ref2[position];
        div.css(options.unsnapped[position]);
      }
      _ref3 = this.divs;
      for (position in _ref3) {
        div = _ref3[position];
        div.animate(options.snapped[position], {
          duration: "fast"
        });
      }
      this.$el.on("keyup mouseup", this.update);
      return $(window).on("resize", this.update);
    };

    Snap.prototype.unsnap = function() {
      var div, options, position, _ref, _ref2;
      if (this.divs) {
        options = this.getFxOptions();
        _ref = this.divs;
        for (position in _ref) {
          div = _ref[position];
          div.css(options.snapped[position]);
        }
        _ref2 = this.divs;
        for (position in _ref2) {
          div = _ref2[position];
          div.animate(options.unsnapped[position], {
            duration: "fast",
            complete: function() {
              return $(this).hide();
            }
          });
        }
        this.$el.off("keyup mouseup", this.update);
        return $(window).off("resize", this.update);
      }
    };

    Snap.prototype.getSnappedStyles = function(elCoords, documentSize) {
      return {
        top: {
          left: elCoords.left,
          width: elCoords.width,
          height: elCoords.top
        },
        bottom: {
          top: elCoords.bottom,
          left: elCoords.left,
          width: elCoords.width,
          height: documentSize.y - elCoords.bottom
        },
        left: {
          width: elCoords.left,
          height: documentSize.y
        },
        right: {
          left: elCoords.right,
          width: documentSize.x - elCoords.right,
          height: documentSize.y
        }
      };
    };

    Snap.prototype.getUnsnappedStyles = function(documentSize, portCoords) {
      return {
        top: {
          left: portCoords.left,
          width: portCoords.width,
          height: portCoords.top
        },
        bottom: {
          top: portCoords.bottom,
          left: portCoords.left,
          width: portCoords.width,
          height: documentSize.y - portCoords.bottom
        },
        left: {
          width: portCoords.left,
          height: documentSize.y
        },
        right: {
          left: portCoords.right,
          width: documentSize.x - portCoords.right,
          height: documentSize.y
        }
      };
    };

    Snap.prototype.getPortCoordinates = function() {
      var winScroll, winSize;
      winScroll = $(window).getScroll();
      winSize = $(window).getSize();
      return {
        top: winScroll.y,
        bottom: winScroll.y + winSize.y,
        left: winScroll.x,
        right: winScroll.x + winSize.x,
        width: winSize.x,
        height: winSize.y
      };
    };

    Snap.prototype.getFxOptions = function() {
      var documentSize, elCoords, portCoords;
      elCoords = this.$el.getCoordinates();
      documentSize = $(document).getSize();
      portCoords = this.getPortCoordinates();
      return {
        snapped: this.getSnappedStyles(elCoords, documentSize),
        unsnapped: this.getUnsnappedStyles(documentSize, portCoords)
      };
    };

    Snap.prototype.update = function() {
      var div, documentSize, elCoord, position, styles, _ref, _results;
      elCoord = this.$el.getCoordinates();
      documentSize = $(document).getSize();
      styles = this.getSnappedStyles(elCoord, documentSize);
      _ref = this.divs;
      _results = [];
      for (position in _ref) {
        div = _ref[position];
        _results.push(div.css(styles[position]));
      }
      return _results;
    };

    Snap.prototype.setCancel = function() {
      return this.isCancel = true;
    };

    Snap.prototype.tryCancel = function() {
      if (this.isCancel) {
        this.isCancel = false;
        return this.api.deactivate();
      }
    };

    return Snap;

  })();
  return Snap;
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define('plugins/autoscroll/autoscroll',["jquery.custom"], function($) {
  var Autoscroll;
  Autoscroll = (function() {

    function Autoscroll() {
      this.autoscroll = __bind(this.autoscroll, this);
      this.stop = __bind(this.stop, this);
      this.start = __bind(this.start, this);
    }

    Autoscroll.prototype.options = {
      topMargin: 50,
      bottomMargin: 50
    };

    Autoscroll.prototype.register = function(api) {
      this.api = api;
      this.api.on("activate.editor", this.start);
      return this.api.on("deactivate.editor", this.stop);
    };

    Autoscroll.prototype.start = function() {
      return $(this.api.el).on("keyup", this.autoscroll);
    };

    Autoscroll.prototype.stop = function() {
      return $(this.api.el).off("keyup", this.autoscroll);
    };

    Autoscroll.prototype.autoscroll = function() {
      var bottomLine, cursor, scroll, topLine, winSize;
      cursor = this.api.getCoordinates();
      scroll = $(window).getScroll();
      winSize = $(window).getSize();
      topLine = cursor.top - this.options.topMargin;
      bottomLine = cursor.bottom + this.options.bottomMargin - winSize.y;
      if (topLine < scroll.y) {
        return window.scrollTo(scroll.x, topLine);
      } else if (bottomLine > scroll.y) {
        return window.scrollTo(scroll.x, bottomLine);
      }
    };

    return Autoscroll;

  })();
  return Autoscroll;
});


define('config/config.default.snap',["config/config.default", "plugins/snap/snap", "plugins/autoscroll/autoscroll"], function(Defaults, Snap, Autoscroll) {
  return {
    build: function() {
      var defaults;
      defaults = Defaults.build();
      return {
        plugins: defaults.plugins.concat([new Snap(), new Autoscroll()]),
        toolbar: defaults.toolbar,
        whitelist: defaults.whitelist
      };
    }
  };
});


define('core/toolbar/toolbar.builder',["jquery.custom", "core/helpers"], function($, Helpers) {
  var ToolbarBuilder;
  ToolbarBuilder = (function() {

    function ToolbarBuilder(template, availableComponents, components) {
      this.availableComponents = availableComponents;
      this.components = components;
      this.$template = $(template);
    }

    ToolbarBuilder.prototype.build = function() {
      var $toolbar, components, css, _ref;
      _ref = this.getComponents(), components = _ref[0], css = _ref[1];
      $toolbar = $(this.$template.mustache({
        componentGroups: components
      }));
      $toolbar.find("[data-action]").each(function() {
        return $(this).attr("unselectable", "on");
      });
      return [$toolbar, css];
    };

    ToolbarBuilder.prototype.getComponents = function() {
      var component, componentCSS, componentHTML, css, groups, html, _i, _len, _ref, _ref2;
      groups = [];
      html = "";
      css = "";
      _ref = this.components;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        component = _ref[_i];
        if (component === "|") {
          groups.push({
            html: html
          });
          html = "";
        } else {
          _ref2 = this.getComponentHtmlAndCss(component), componentHTML = _ref2[0], componentCSS = _ref2[1];
          html += componentHTML;
          css += componentCSS;
        }
      }
      if (html.length !== 0) {
        groups.push({
          html: html
        });
      }
      return [groups, css];
    };

    ToolbarBuilder.prototype.getComponentHtmlAndCss = function(key) {
      var component, componentCSS, componentHTML, components, css, html, _i, _len, _ref, _ref2;
      html = "";
      css = "";
      components = this.availableComponents[key.toLowerCase()];
      if (!components) {
        throw "The component(s) for " + key + " is not available. Please check that the plugin has been included.";
      }
      for (_i = 0, _len = components.length; _i < _len; _i++) {
        component = components[_i];
        switch (Helpers.typeOf(component)) {
          case "string":
            _ref = this.getComponentHtmlAndCss(component), componentHTML = _ref[0], componentCSS = _ref[1];
            break;
          case "object":
            _ref2 = [component.htmlForToolbar(), component.cssForToolbar()], componentHTML = _ref2[0], componentCSS = _ref2[1];
            break;
          default:
            throw "Unrecognized component format for '" + key + "'. Expecting a string or UI component object";
        }
        html += componentHTML;
        css += componentCSS;
      }
      return [html, css];
    };

    return ToolbarBuilder;

  })();
  return ToolbarBuilder;
});


define('core/toolbar/toolbar',["jquery.custom", "core/helpers", "core/data_action_handler", "core/toolbar/toolbar.builder"], function($, Helpers, DataActionHandler, Builder) {
  var Toolbar;
  Toolbar = (function() {

    function Toolbar(api, templates, availableComponents, components) {
      this.api = api;
      this.availableComponents = availableComponents;
      this.components = components;
      this.$templates = $(templates);
      this.$toolbar = null;
      this.setupTemplates();
    }

    Toolbar.prototype.setupTemplates = function() {
      this.$template = this.$templates.find("#snapeditor_toolbar_template");
      if (this.$template.length === 0) {
        throw "Missing template. Make sure there is an element with id snapeditor_toolbar_template.";
      }
    };

    Toolbar.prototype.setup = function() {
      var _ref;
      _ref = new Builder(this.$template, this.availableComponents, this.components).build(), this.$toolbar = _ref[0], this.css = _ref[1];
      this.dataActionHandler = new DataActionHandler(this.$toolbar, this.api);
      return Helpers.insertStyles(this.css);
    };

    return Toolbar;

  })();
  return Toolbar;
});


define('core/toolbar/toolbar.floating.displayer.styles',["jquery.custom", "core/browser"], function($, Browser) {
  var Styles;
  Styles = (function() {

    function Styles(el, floater) {
      this.$el = $(el);
      this.$floater = $(floater);
    }

    Styles.prototype.top = function() {
      var styles;
      if (this.doesFloaterFit("top")) {
        styles = {
          position: "absolute",
          top: this.elCoords().top - this.floaterSize().y
        };
      } else {
        styles = this.topFixed();
      }
      return $.extend(styles, this.x());
    };

    Styles.prototype.bottom = function() {
      var styles;
      if (this.doesFloaterFit("bottom")) {
        styles = {
          position: "absolute",
          top: this.elCoords().bottom
        };
      } else {
        styles = this.bottomFixed();
      }
      return $.extend(styles, this.x());
    };

    Styles.prototype.elCoords = function() {
      return this.$el.getCoordinates();
    };

    Styles.prototype.floaterSize = function() {
      return this.$floater.getSize();
    };

    Styles.prototype.x = function() {
      var floaterLeft, floaterSize, windowSize;
      floaterSize = this.floaterSize();
      windowSize = $(window).getSize();
      floaterLeft = this.elCoords().left;
      if (floaterLeft < 0) {
        floaterLeft = 0;
      } else if (floaterLeft + floaterSize.x > windowSize.x) {
        floaterLeft = windowSize.x - floaterSize.x;
      }
      return {
        left: floaterLeft
      };
    };

    Styles.prototype.spaceBetweenElAndWindow = function(where) {
      var elCoords, space, windowScroll;
      elCoords = this.elCoords();
      windowScroll = $(window).getScroll();
      space = 0;
      if (where === "top") {
        space = elCoords.top - windowScroll.y;
      } else {
        space = windowScroll.y + $(window).getSize().y - elCoords.bottom;
      }
      return space;
    };

    Styles.prototype.doesFloaterFit = function(where) {
      return this.spaceBetweenElAndWindow(where) >= this.floaterSize().y;
    };

    Styles.prototype.topFixed = function() {
      if (Browser.isIE) {
        return {
          position: "absolute",
          top: $(window).getScroll().y
        };
      } else {
        return {
          position: "fixed",
          top: 0
        };
      }
    };

    Styles.prototype.bottomFixed = function() {
      if (Browser.isIE) {
        return {
          position: "absolute",
          top: $(window).getScroll().y + $(window).getSize().y - this.floaterSize().y
        };
      } else {
        return {
          position: "fixed",
          top: $(window).getSize().y - this.floaterSize().y
        };
      }
    };

    return Styles;

  })();
  return Styles;
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define('core/toolbar/toolbar.floating.displayer',["jquery.custom", "core/toolbar/toolbar.floating.displayer.styles"], function($, Styles) {
  var Displayer;
  Displayer = (function() {

    function Displayer(toolbar, el, api) {
      this.api = api;
      this.updateAndCheckCursor = __bind(this.updateAndCheckCursor, this);
      this.update = __bind(this.update, this);
      this.hide = __bind(this.hide, this);
      this.show = __bind(this.show, this);
      this.$toolbar = $(toolbar);
      this.$el = $(el);
      this.shown = false;
      this.positionedAtTop = true;
      this.$toolbar.hide().appendTo("body");
    }

    Displayer.prototype.getHeight = function() {
      return parseInt(this.$toolbar.css('height'));
    };

    Displayer.prototype.setup = function() {
      this.styles = new Styles(this.$el, this.$toolbar);
      $(window).on("scroll resize", this.update);
      return this.$el.on("mouseup keyup", this.updateAndCheckCursor);
    };

    Displayer.prototype.teardown = function() {
      $(window).off("scroll resize", this.update);
      return this.$el.off("mouseup keyup", this.updateAndCheckCursor);
    };

    Displayer.prototype.show = function() {
      if (!this.shown) {
        this.setup();
        this.$toolbar.show();
        this.shown = true;
        return this.updateAndCheckCursor();
      }
    };

    Displayer.prototype.hide = function() {
      if (this.shown) {
        this.$toolbar.hide();
        this.shown = false;
        return this.teardown();
      }
    };

    Displayer.prototype.update = function(checkCursor) {
      if (this.shown) {
        if (this.positionedAtTop) {
          this.positionAtTop();
          if (checkCursor && this.isCursorInOverlapSpace()) {
            return this.moveToBottom();
          }
        } else {
          this.positionAtBottom();
          if (checkCursor && !this.isCursorInOverlapSpace()) {
            return this.moveToTop();
          }
        }
      }
    };

    Displayer.prototype.updateAndCheckCursor = function() {
      return this.update(true);
    };

    Displayer.prototype.elCoords = function() {
      return this.$el.getCoordinates();
    };

    Displayer.prototype.toolbarSize = function() {
      return this.$toolbar.getSize();
    };

    Displayer.prototype.cursorPosition = function() {
      return this.api.getCoordinates().top;
    };

    Displayer.prototype.positionAtTop = function() {
      this.positionedAtTop = true;
      return this.$toolbar.css(this.styles.top());
    };

    Displayer.prototype.positionAtBottom = function() {
      this.positionedAtTop = false;
      return this.$toolbar.css(this.styles.bottom());
    };

    Displayer.prototype.moveToTop = function() {
      this.positionedAtTop = true;
      return this.$toolbar.animate(this.styles.top(), {
        duration: 'fast'
      });
    };

    Displayer.prototype.moveToBottom = function() {
      this.positionedAtTop = false;
      return this.$toolbar.animate(this.styles.bottom(), {
        duration: 'fast'
      });
    };

    Displayer.prototype.overlapSpaceFromElTop = function() {
      var elCoords, overlap;
      elCoords = this.elCoords();
      overlap = this.toolbarSize().y - elCoords.top;
      if (overlap > 0) {
        return overlap;
      } else {
        return 0;
      }
    };

    Displayer.prototype.isCursorInOverlapSpace = function() {
      var cursorPositionInEl;
      cursorPositionInEl = this.cursorPosition() - this.elCoords().top;
      return cursorPositionInEl < this.overlapSpaceFromElTop();
    };

    return Displayer;

  })();
  return Displayer;
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

define('core/toolbar/toolbar.floating',["core/toolbar/toolbar", "core/toolbar/toolbar.floating.displayer"], function(Toolbar, Displayer) {
  var FloatingToolbar;
  FloatingToolbar = (function(_super) {

    __extends(FloatingToolbar, _super);

    function FloatingToolbar() {
      this.hide = __bind(this.hide, this);
      this.show = __bind(this.show, this);      FloatingToolbar.__super__.constructor.apply(this, arguments);
      this.api.on("activate.editor", this.show);
      this.api.on("deactivate.editor", this.hide);
    }

    FloatingToolbar.prototype.setup = function() {
      FloatingToolbar.__super__.setup.apply(this, arguments);
      this.$toolbar.addClass("snapeditor_toolbar_floating");
      return this.displayer = new Displayer(this.$toolbar, this.api.el, this.api);
    };

    FloatingToolbar.prototype.show = function() {
      if (!this.$toolbar) this.setup();
      return this.displayer.show();
    };

    FloatingToolbar.prototype.hide = function() {
      if (this.$toolbar) return this.displayer.hide();
    };

    return FloatingToolbar;

  })(Toolbar);
  return FloatingToolbar;
});

var __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

define('core/editor.snap',["core/editor", "config/config.default.snap", "core/toolbar/toolbar.floating"], function(Editor, Defaults, Toolbar) {
  var SnapEditor;
  SnapEditor = (function(_super) {

    __extends(SnapEditor, _super);

    function SnapEditor(el, config) {
      var toolbarComponents;
      SnapEditor.__super__.constructor.call(this, el, Defaults.build(), config);
      toolbarComponents = this.plugins.getToolbarComponents();
      this.toolbar = new Toolbar(this.api, this.$templates, toolbarComponents.available, toolbarComponents.config);
    }

    return SnapEditor;

  })(Editor);
  return SnapEditor;
});


define('config/config.default.form',["config/config.default"], function(Defaults) {
  return {
    build: function() {
      return Defaults.build();
    }
  };
});


define('core/formizer',["jquery.custom", "core/browser"], function($, Browser) {
  var Formizer;
  Formizer = (function() {

    function Formizer(el) {
      this.$el = $(el);
      this.$content = $("<div/>").addClass("snapeditor_form_content").html(this.$el.html()).hide().appendTo("body");
    }

    Formizer.prototype.formize = function(toolbar) {
      var $toolbar, elCoords, toolbarCoords;
      $toolbar = $(toolbar);
      toolbarCoords = $toolbar.measure(function() {
        return this.getCoordinates();
      });
      elCoords = this.$el.getCoordinates();
      this.$content.css({
        height: elCoords.height - toolbarCoords.height,
        overflowX: "auto",
        overflowY: Browser.isIE ? "scroll" : "auto"
      });
      this.$el.empty().append($toolbar.show()).append(this.$content.show());
      return this.$el.addClass("snapeditor_form");
    };

    return Formizer;

  })();
  return Formizer;
});

var __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

define('core/toolbar/toolbar.static',["core/toolbar/toolbar"], function(Toolbar) {
  var StaticToolbar;
  StaticToolbar = (function(_super) {

    __extends(StaticToolbar, _super);

    function StaticToolbar() {
      StaticToolbar.__super__.constructor.apply(this, arguments);
      this.setup();
      this.$toolbar.hide().appendTo("body");
    }

    StaticToolbar.prototype.setup = function() {
      StaticToolbar.__super__.setup.apply(this, arguments);
      return this.$toolbar.addClass("snapeditor_toolbar_static");
    };

    StaticToolbar.prototype.show = function() {
      return this.$toolbar.show();
    };

    return StaticToolbar;

  })(Toolbar);
  return StaticToolbar;
});

var __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

define('core/editor.form',["core/editor", "config/config.default.form", "core/formizer", "core/toolbar/toolbar.static"], function(Editor, Defaults, Formizer, Toolbar) {
  var FormEditor;
  FormEditor = (function(_super) {

    __extends(FormEditor, _super);

    function FormEditor(el, config) {
      var toolbarComponents;
      this.formizer = new Formizer($(el));
      FormEditor.__super__.constructor.call(this, this.formizer.$content, Defaults.build(), config);
      toolbarComponents = this.plugins.getToolbarComponents();
      this.toolbar = new Toolbar(this.api, this.$templates, toolbarComponents.available, toolbarComponents.config);
      this.formizer.formize(this.toolbar.$toolbar);
    }

    return FormEditor;

  })(Editor);
  return FormEditor;
});


require(["core/editor.snap", "core/editor.form"], (function(SnapEditor, FormEditor) {
  return window.SnapEditor = {
    Snap: SnapEditor,
    Form: FormEditor
  };
}), null, true);

define("snapeditor", function(){});
}());