import "./global.css";

import { Toaster } from "@/components/ui/toaster";
import { createRoot } from "react-dom/client";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route, Link } from "react-router-dom";
import Index from "./pages/Index";
import NotFound from "./pages/NotFound";

const queryClient = new QueryClient();

const Header = () => (
  <header className="bg-white/60 backdrop-blur-sm sticky top-0 z-40 border-b border-border">
    <div className="max-w-6xl mx-auto px-6 py-3 flex items-center justify-between">
      <Link to="/" className="flex items-center gap-3 no-underline">
        <div className="w-9 h-9 rounded-md bg-gradient-to-br from-sky-600 to-indigo-600 text-white flex items-center justify-center font-bold">
          BE
        </div>
        <div className="text-slate-900 font-semibold">Backend API</div>
      </Link>
      <nav className="flex items-center gap-4 text-sm text-slate-700">
        <a href="#" className="opacity-70">
          Docs
        </a>
        <a href="#" className="opacity-70">
          Support
        </a>
      </nav>
    </div>
  </header>
);

const App = () => (
  <QueryClientProvider client={queryClient}>
    <TooltipProvider>
      <Toaster />
      <Sonner />
      <BrowserRouter>
        <Header />
        <Routes>
          <Route path="/" element={<Index />} />
          {/* ADD ALL CUSTOM ROUTES ABOVE THE CATCH-ALL "*" ROUTE */}
          <Route path="*" element={<NotFound />} />
        </Routes>
      </BrowserRouter>
    </TooltipProvider>
  </QueryClientProvider>
);

createRoot(document.getElementById("root")!).render(<App />);
