if (document.documentElement.uniqueID) (function ($, document_) {
	function size() {
		var root = document_.documentElement,
		    body = document_.body;
		return {
			w: root && root.clientWidth  || body.clientWidth,
			h: root && root.clientHeight || body.clientHeight
		};
	}
	var lock_ = 0, size_, use_;
	$.event.special.resize = {
		setup: function () {
			if (!this.setTimeout)
				return false;
			size_ = size();
			use_ = true;
			(function loop() {
				if (!lock_++) {
					var now = size();
					if (size_.w !== now.w || size_.h !== now.h) {
						size_ = now;
						var evt = $.Event("resize");
						evt.target = evt.originalTarget = evt.currentTarget = window;
						$.event.handle.call(this, evt);
					}
					setTimeout(function() { lock_ = 0; }, 0);
				}
				if (use_) {
					setTimeout(loop, 100);
				}
			})();
		},
		teardown: function () {
			if (!this.setTimeout)
				return false;
			use_ = false;
		}
	};
})(jQuery, document);