class DTICalculator
  constructor: ->
    $.getJSON '/loan-matrix.json', (data) =>
      @matrix = data
    $(".monthly-income input, .debt-payments input, .credit-score input").focusout =>
      @calculate()

  sumFormGroup: (group_name) =>
    inputs = $(".#{group_name} input")
    values = (parseFloat(el.value) for el in inputs)
    values.reduce (acc, e)->
      return acc if isNaN(e)
      acc + e
    ,0

  ratio: (debt, monthly) =>
    n = debt / monthly
    return 0 if isNaN(n)
    parseInt(n*100)

  creditScore: =>
    parseInt($("#input-credit-score").val())

  maxDti: =>
    cs = @creditScore()
    if cs > 720
      1
    else if 640 <= cs <= 720
      0.55
    else if 590 <= cs <= 639
      0.45
    else if 530 <= cs <= 589
      0.40
    else if cs < 530
      0.35
    else
      0

  maxPayment: (ratio) =>
    n = (@maxDti() - (ratio/100)).toFixed(2)
    console.log "#{@maxDti()} - (#{ratio/100}) = #{n}"
    return 0 if isNaN(n)
    parseInt(n*100)

  qualifying: (maxPaymentPercentage, totalMonthlyIncome) =>
    n = maxPaymentPercentage * (totalMonthlyIncome / 100)
    return 0 if isNaN(n)
    n.toFixed(2)

  calculate: =>
    tmnth = @sumFormGroup('monthly-income').toFixed(2)
    tdebt = @sumFormGroup('debt-payments').toFixed(2)
    ratio = @ratio(tdebt, tmnth)
    maxPm = @maxPayment(ratio)
    quali = @qualifying(maxPm, tmnth)
    $('#monthly-income').val(tmnth)
    $('#debt-payments').val(tdebt)
    $('#dti-ratio').val(NumberHelpers.number_to_percentage(ratio, {precision: 0}))
    $('#max-payment').val(NumberHelpers.number_to_percentage(maxPm, {precision: 0}))
    $('#qualifying-amount').val(NumberHelpers.number_to_currency(quali))

    lookup = @matrixLookup(quali)
    actual = lookup["loan_amount"] || 0

    if actual > 0
      post_deductions = actual - @creditScoreDeductions(actual)
      if post_deductions <= 0
        actual = 0
      else
        actual = post_deductions

    $(".loan-amount").html(NumberHelpers.number_to_currency(actual))

    for i in [1..8]
      str = "payment-#{i}"
      amt = lookup[str] || 0
      $(".#{str}").html(NumberHelpers.number_to_currency(amt))


  matrixLookup: (qualified) =>
    candidate = 0
    candidate_delta = 9999999
    for k,v of @matrix
      taac = parseFloat(k).toFixed(2) # total amount after charges (aka payment-1)
      delta = qualified - taac
      if delta >= 0 && delta < candidate_delta
        candidate = v
        candidate_delta = delta
    candidate

  creditScoreDeductions: (amount)=>
    score = @creditScore()
    return 0 if isNaN(score) || score == undefined
    threshold = @creditScoreThreshold(amount)

    delta = threshold - score
    if delta > 0
      100 * parseInt(delta/50)
    else
      0

  creditScoreThreshold: (amount)=>
    if 100.00 <= amount <= 300
      500
    else if 300.01 <= amount <= 500
      550
    else if 500.01 <= amount <= 800
      650
    else if 800.01 <= amount
      700
    else
      0

jQuery ->
  new DTICalculator()