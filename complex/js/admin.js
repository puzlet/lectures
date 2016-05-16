// Generated by CoffeeScript 1.7.1
(function() {
  var Admin, Server;

  Server = (function() {
    function Server() {}

    Server.local = "//puzlet.mvclark.dev";

    Server["public"] = "//puzlet.mvclark.com";

    Server.isLocal = window.location.hostname === "localhost";

    Server.url = Server.isLocal ? Server.local : Server["public"];

    Server.getAll = function(callback) {
      return $.get("" + this.url, function(data) {
        this.data = data;
        console.log("All exercises from server", this.data);
        return typeof callback === "function" ? callback(this.data) : void 0;
      });
    };

    return Server;

  })();

  Admin = (function() {
    Admin.prototype.exerciseIds = {
      '1.1': 'complex-plane-1',
      '1.2': 'complex-plane-2',
      '2.1': 'complex-addition-1',
      '2.2': 'complex-addition-2',
      '2.3': 'complex-addition-3',
      '3.1': 'complex-unit-1',
      '3.2': 'complex-unit-2',
      '3.3': 'complex-unit-3',
      '3.4': 'complex-unit-4',
      '3.5': 'complex-unit-5'
    };

    function Admin() {
      $(document).tooltip({
        content: function() {
          return $(this).prop('title');
        }
      });
      Server.getAll((function(_this) {
        return function(data) {
          _this.data = data;
          _this.model();
          console.log("report", _this.report);
          _this.viewSummary();
          return _this.viewDetail();
        };
      })(this));
    }

    Admin.prototype.model = function() {
      var rec, record, _base, _i, _len, _name, _ref, _results;
      this.report = {};
      _ref = this.data;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        record = _ref[_i];
        rec = (_base = this.report)[_name = record.userId] != null ? _base[_name] : _base[_name] = {};
        this.blankExerciseRecords(rec);
        _results.push(rec[this.trimExerciseId(record.exerciseId)] = {
          correct: record.correct,
          code: record.code
        });
      }
      return _results;
    };

    Admin.prototype.blankExerciseRecords = function(rec) {
      var ex, id, _ref, _results;
      if (rec[this.exerciseIds['1.1']]) {
        return;
      }
      _ref = this.exerciseIds;
      _results = [];
      for (ex in _ref) {
        id = _ref[ex];
        _results.push(rec[id] = {});
      }
      return _results;
    };

    Admin.prototype.viewSummary = function() {
      var a, e, ex, exercise, exerciseId, id, summaryContainer, text, user, userContainer, userExercises, _ref, _ref1, _results;
      this.container = $("#report");
      summaryContainer = this.div("summary", null, this.container);
      userContainer = this.div("user-summary", null, summaryContainer);
      this.div("user-id-summary", null, userContainer);
      _ref = this.exerciseIds;
      for (ex in _ref) {
        id = _ref[ex];
        e = this.div("exercise-heading", ex, userContainer);
        e.attr({
          title: id
        });
      }
      _ref1 = this.report;
      _results = [];
      for (user in _ref1) {
        userExercises = _ref1[user];
        userContainer = this.div("user-summary", null, summaryContainer);
        a = $("<a>", {
          href: "#" + user,
          target: "_self",
          text: user
        });
        this.div("user-id-summary", a, userContainer);
        _results.push((function() {
          var _ref2, _results1;
          _results1 = [];
          for (exerciseId in userExercises) {
            exercise = userExercises[exerciseId];
            e = this.div("exercise-summary", null, userContainer);
            this.answer(e, exercise.correct);
            text = this.summaryTextTemplate(exerciseId, (_ref2 = exercise.code) != null ? _ref2 : "No answer");
            _results1.push(e.attr({
              title: text
            }));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    Admin.prototype.summaryTextTemplate = function(id, code) {
      var text;
      return text = "<div class='text-summary'>\n  <b>" + id + "</b>\n  <pre>" + code + "</pre>\n</div>";
    };

    Admin.prototype.viewDetail = function() {
      var code, correct, exercise, exerciseContainer, exerciseId, id, user, userContainer, userExercises, _ref, _results;
      this.container = $("#report");
      _ref = this.report;
      _results = [];
      for (user in _ref) {
        userExercises = _ref[user];
        userContainer = this.div("user", null, this.container);
        userContainer.attr({
          id: user
        });
        this.div("user-id", user, userContainer);
        _results.push((function() {
          var _results1;
          _results1 = [];
          for (exerciseId in userExercises) {
            exercise = userExercises[exerciseId];
            correct = exercise.correct;
            if (correct == null) {
              continue;
            }
            exerciseContainer = this.div("exercise", null, userContainer);
            this.answer(exerciseContainer, correct);
            id = this.div("exercise-id", exerciseId);
            code = this.div("exercise-code", "<pre>" + exercise.code + "</pre>");
            _results1.push(exerciseContainer.append(id).append(code));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    Admin.prototype.div = function(cls, content, container) {
      var div;
      div = $("<div>", {
        "class": cls
      });
      if (content) {
        div.append(content);
      }
      if (container) {
        container.append(div);
      }
      return div;
    };

    Admin.prototype.trimExerciseId = function(id) {
      var prefix;
      prefix = "exercise-";
      if (id.indexOf(prefix) === 0) {
        id = id.substr(prefix.length);
      }
      return id;
    };

    Admin.prototype.answer = function(element, correct) {
      return element.addClass(correct != null ? (correct ? "correct" : "incorrect") : "not-done");
    };

    Admin.prototype.append = function(element) {
      return this.container.append(element);
    };

    return Admin;

  })();

  new Admin;

}).call(this);
