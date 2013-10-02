CustomEventSupport = Module('CustomEventSupport')({
    eventListeners : null,
    bind : function(type, eventHandler){
        if(!this.eventListeners){
            this.eventListeners = {};
        }

        if(!this.eventListeners[type]){
            this.eventListeners[type] = [];
        }

        if (this.eventListeners[type].indexOf(eventHandler) == -1) {
            this.eventListeners[type].push(eventHandler);
        }

        return this;
    },
    unbind : function(type, eventHandler){
        var i;

        if (!this.eventListeners) {
            this.eventListeners = {};
        }

        if (typeof eventHandler === "undefined") {
            this.eventListeners[type] = [];
        }

        i = (this.eventListeners[type] || []).indexOf(eventHandler);

        if (i > -1) {
            this.eventListeners[type].splice(i, 1);
        }

        return this;
    },
    dispatch : function(type, data){
            var event, listeners, instance, i;

            if (this.eventListeners === null) {
                this.eventListeners = {};
            }

            if (typeof data === 'undefined') {
                data = {};
            }

            if (data.hasOwnProperty('target') === false) {
                data.target = this;
            }

            event         = new CustomEvent(type, data);
            listeners     = this.eventListeners[type] || [];
            instance      = this;

            for (i = 0; i < listeners.length; i = i + 1) {
                listeners[i].call(instance, event);
                if (event.areImmediateHandlersPrevented === true) {
                    break;
                }
            }

            return event;
    },
    prototype : {
        eventListeners : null,
        bind : function(type, eventHandler){
            if(!this.eventListeners){
                this.eventListeners = {};
            }

            if(!this.eventListeners[type]){
                this.eventListeners[type] = [];
            }

            if (this.eventListeners[type].indexOf(eventHandler) == -1) {
                this.eventListeners[type].push(eventHandler);
            }

            return this;
        },
        unbind : function(type, eventHandler){
            var i;

            if (!this.eventListeners) {
                this.eventListeners = {};
            }

            if (typeof eventHandler === "undefined") {
                this.eventListeners[type] = [];
            }

            i = (this.eventListeners[type] || []).indexOf(eventHandler);

            if (i > -1) {
                this.eventListeners[type].splice(i, 1);
            }

            return this;
        },
        dispatch : function(type, data){
            var event, listeners, instance, i;

            if (this.eventListeners === null) {
                this.eventListeners = {};
            }

            if (typeof data === 'undefined') {
                data = {};
            }

            if (data.hasOwnProperty('target') === false) {
                data.target = this;
            }

            event         = new CustomEvent(type, data);
            listeners     = this.eventListeners[type] || [];
            instance      = this;

            for (i = 0; i < listeners.length; i = i + 1) {
                listeners[i].call(instance, event);
                if (event.areImmediateHandlersPrevented === true) {
                    break;
                }
            }

            return event;
        }
    }
});

