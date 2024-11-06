local Translations = {
    error = {
        not_enough_money = "You don't have enough money for this service",
        service_on_cooldown = "This service is on cooldown. Please wait %{time} seconds",
        cant_afford = "You can't afford this service!",
    },
    success = {
        payment_received = "You paid $%{amount} for %{service}",
        stress_relieved = "You feel more relaxed! Stress reduced by %{amount} points",
    },
    info = {
        using_service = "Enjoying %{service}...",
        current_stress = "Your current stress level is %{stress}",
    },
    progress = {
        tanning_bed = "Relaxing in the tanning bed",
        hot_tub = "Soaking in the hot tub",
        shower = "Taking a refreshing shower",
        sauna = "Sweating it out in the sauna",
        meditation = "Meditating for inner peace",
    },
    target = {
        use_tanning_bed = "Use Tanning Bed",
        use_hot_tub = "Use Hot Tub",
        use_shower = "Use Shower",
        use_sauna = "Use Sauna",
        use_meditation_mat = "Use Meditation Mat",
    },
    blip = {
        wellness_center = "Wellness Center",
    },
}

if GetConvar('qb_locale', 'en') == 'en' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end